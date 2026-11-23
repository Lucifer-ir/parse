from fastapi import FastAPI, HTTPException, Depends, UploadFile, File, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from passlib.context import CryptContext
import sqlite3, os, secrets, hashlib, json, httpx, datetime

APP_DIR=os.path.dirname(__file__)
ROOT=os.path.dirname(APP_DIR)
def envfile(path):
    if not os.path.exists(path): return
    for line in open(path,encoding="utf-8"):
        line=line.strip()
        if not line or line.startswith("#") or "=" not in line: continue
        k,v=line.split("=",1)
        os.environ.setdefault(k.strip(),v.strip().strip('"').strip("'"))
envfile(os.path.join(ROOT,'.env'))
DB=os.getenv("DATABASE_PATH",os.path.join(ROOT,"parse.db"))
pwd=CryptContext(schemes=["bcrypt"],deprecated="auto")
app=FastAPI(title="Parse Academy API",version="0.1.0")
origins=[s.strip() for s in os.getenv("CORS_ORIGINS","").split(",") if s.strip()]
app.add_middleware(CORSMiddleware,allow_origins=origins,allow_credentials=False,allow_methods=["GET","POST","OPTIONS"],allow_headers=["Authorization","Content-Type"])
def db():
 c=sqlite3.connect(DB);c.row_factory=sqlite3.Row;return c
def init():
 c=db()
 c.executescript("""
 CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, username TEXT UNIQUE NOT NULL, phone TEXT UNIQUE, name TEXT DEFAULT '', password_hash TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'student', created_at TEXT DEFAULT CURRENT_TIMESTAMP);
 CREATE TABLE IF NOT EXISTS tokens(token_hash TEXT PRIMARY KEY,user_id INTEGER NOT NULL,expires_at TEXT NOT NULL);
 CREATE TABLE IF NOT EXISTS sources(id INTEGER PRIMARY KEY,owner_id INTEGER,title TEXT,content TEXT,created_at TEXT DEFAULT CURRENT_TIMESTAMP);
 CREATE TABLE IF NOT EXISTS questions(id INTEGER PRIMARY KEY,source_id INTEGER,owner_id INTEGER,question TEXT,answer TEXT,level TEXT,kind TEXT,created_at TEXT DEFAULT CURRENT_TIMESTAMP);
 CREATE TABLE IF NOT EXISTS fcm_tokens(user_id INTEGER,token TEXT,platform TEXT,created_at TEXT DEFAULT CURRENT_TIMESTAMP,UNIQUE(user_id,token));
 """);c.commit();c.close()
init()
class Register(BaseModel):
 username:str=Field(min_length=2,max_length=100);password:str=Field(min_length=8);phone:str|None=None;name:str=""
class Login(BaseModel): username:str;password:str
class FcmToken(BaseModel): token:str;platform:str="unknown"
class Generate(BaseModel): source_id:int;count:int=Field(ge=1,le=100);level:str="mixed";kind:str="mixed"
def tokenhash(t):return hashlib.sha256(t.encode()).hexdigest()
def auth(authorization:str|None=Header(default=None)):
 if not authorization or not authorization.startswith("Bearer "):raise HTTPException(401,"Authentication required")
 t=authorization[7:];c=db();r=c.execute("SELECT user_id FROM tokens WHERE token_hash=? AND expires_at>?",(tokenhash(t),datetime.datetime.utcnow().isoformat())).fetchone();c.close()
 if not r:raise HTTPException(401,"Invalid or expired token")
 return int(r["user_id"])
@app.get("/health")
def health():return {"ok":True,"service":"parse-python-api"}
@app.post("/auth/register")
def register(data:Register):
 c=db()
 try:
  c.execute("INSERT INTO users(username,phone,name,password_hash,role) VALUES(?,?,?,?,?)",(data.username,data.phone,data.name,pwd.hash(data.password),"student"));uid=c.execute("SELECT last_insert_rowid()").fetchone()[0];c.commit()
 except sqlite3.IntegrityError: c.close();raise HTTPException(409,"Username or phone already exists")
 c.close();return {"user_id":uid}
@app.post("/auth/login")
def login(data:Login):
 c=db();r=c.execute("SELECT * FROM users WHERE username=? OR phone=?",(data.username,data.username)).fetchone()
 if not r or not pwd.verify(data.password,r["password_hash"]):c.close();raise HTTPException(401,"Invalid credentials")
 t=secrets.token_hex(32);exp=(datetime.datetime.utcnow()+datetime.timedelta(days=30)).isoformat()
 c.execute("INSERT INTO tokens VALUES(?,?,?)",(tokenhash(t),r["id"],exp));c.commit();c.close()
 return {"token":t,"user":{"id":r["id"],"username":r["username"],"name":r["name"],"role":r["role"]}}
@app.get("/auth/me")
def me(uid:int=Depends(auth)):
 c=db();r=c.execute("SELECT id,username,name,role FROM users WHERE id=?",(uid,)).fetchone();c.close();return {"user":dict(r)}
@app.post("/auth/logout")
def logout(authorization:str|None=Header(default=None),uid:int=Depends(auth)):
 t=authorization[7:];c=db();c.execute("DELETE FROM tokens WHERE token_hash=?",(tokenhash(t),));c.commit();c.close();return {"ok":True}
@app.post("/notifications/token")
def register_fcm(data:FcmToken,uid:int=Depends(auth)):
 c=db();c.execute("INSERT OR IGNORE INTO fcm_tokens(user_id,token,platform) VALUES(?,?,?)",(uid,data.token,data.platform));c.commit();c.close();return {"registered":True,"note":"Firebase Admin delivery must be configured server-side"}
@app.post("/sources/upload")
async def upload_source(file:UploadFile=File(...),uid:int=Depends(auth)):
 limit=int(os.getenv("MAX_UPLOAD_BYTES","10485760"))
 if not (file.filename or "").lower().endswith((".txt",".md")):raise HTTPException(415,"Only TXT/Markdown files supported in this starter")
 data=await file.read(limit+1)
 if len(data)>limit:raise HTTPException(413,"File exceeds upload limit")
 try:content=data.decode("utf-8")
 except UnicodeDecodeError:raise HTTPException(400,"File must be UTF-8 text")
 c=db();c.execute("INSERT INTO sources(owner_id,title,content) VALUES(?,?,?)",(uid,file.filename,content));sid=c.execute("SELECT last_insert_rowid()").fetchone()[0];c.commit();c.close()
 return {"source_id":sid,"title":file.filename}
@app.post("/ai/questions/generate")
async def generate(data:Generate,uid:int=Depends(auth)):
 key=os.getenv("PAASTA_AI_KEY","");model=os.getenv("PAASTA_AI_MODEL","")
 if not key or not model:raise HTTPException(503,"AI provider key/model is not configured")
 c=db();src=c.execute("SELECT * FROM sources WHERE id=? AND owner_id=?",(data.source_id,uid)).fetchone()
 if not src:c.close();raise HTTPException(404,"Source not found")
 prompt=f"""Create {data.count} educational questions based strictly on this source. Level: {data.level}. Type: {data.kind}. Return only valid JSON array. Each item must contain question, answer, level, kind. Source text:\n{src['content']}"""
 c.close()
 url=os.getenv("PAASTA_AI_BASE_URL","https://console.paasta.cloud/api/ai/v1").rstrip("/")+"/chat/completions"
 async with httpx.AsyncClient(timeout=90) as client:
  try:r=await client.post(url,headers={"Authorization":"Bearer "+key,"Content-Type":"application/json"},json={"model":model,"messages":[{"role":"user","content":prompt}],"max_tokens":3000})
  except Exception:raise HTTPException(502,"AI provider unavailable")
 if r.status_code>=300:raise HTTPException(502,"AI provider rejected request")
 try:
  raw=r.json()["choices"][0]["message"]["content"];questions=json.loads(raw)
 except Exception:raise HTTPException(502,"AI output was not valid JSON")
 if not isinstance(questions,list):raise HTTPException(502,"AI output format invalid")
 c=db();saved=[]
 for q in questions[:data.count]:
  if not isinstance(q,dict) or not q.get("question"):continue
  c.execute("INSERT INTO questions(source_id,owner_id,question,answer,level,kind) VALUES(?,?,?,?,?,?)",(data.source_id,uid,str(q["question"]),str(q.get("answer","")),str(q.get("level",data.level)),str(q.get("kind",data.kind))))
  saved.append({"question":q["question"],"answer":q.get("answer",""),"level":q.get("level",data.level),"kind":q.get("kind",data.kind)})
 c.commit();c.close();return {"created":len(saved),"questions":saved}
@app.get("/questions")
def questions(uid:int=Depends(auth)):
 c=db();rows=c.execute("SELECT id,source_id,question,answer,level,kind FROM questions WHERE owner_id=? ORDER BY id DESC",(uid,)).fetchall();c.close();return [dict(r) for r in rows]

def admin_auth(uid:int=Depends(auth)):
 c=db();r=c.execute("SELECT role FROM users WHERE id=?",(uid,)).fetchone();c.close()
 if not r or r["role"]!="admin":raise HTTPException(403,"Admin access required")
 return uid
@app.get("/admin/stats")
def admin_stats(uid:int=Depends(admin_auth)):
 c=db()
 users=c.execute("SELECT COUNT(*) FROM users").fetchone()[0]
 sources=c.execute("SELECT COUNT(*) FROM sources").fetchone()[0]
 questions=c.execute("SELECT COUNT(*) FROM questions").fetchone()[0]
 c.close()
 return {"users":users,"sources":sources,"questions":questions}

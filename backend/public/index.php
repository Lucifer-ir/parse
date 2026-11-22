<?php
declare(strict_types=1);
require __DIR__.'/../src/bootstrap.php';
require __DIR__.'/../src/auth.php';
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('Cache-Control: no-store');
$origin=$_SERVER['HTTP_ORIGIN']??'';
$allowed=array_filter(array_map('trim',explode(',',envv('CORS_ORIGINS',''))));
if($origin!=='' && in_array($origin,$allowed,true)){header('Access-Control-Allow-Origin: '.$origin);header('Vary: Origin');}
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
if($_SERVER['REQUEST_METHOD']==='OPTIONS'){http_response_code(204);exit;}
$path=parse_url($_SERVER['REQUEST_URI']??'/',PHP_URL_PATH);$path=preg_replace('#^/api#','',$path);$method=$_SERVER['REQUEST_METHOD'];
$data=json_decode(file_get_contents('php://input'),true); if(!is_array($data)) $data=[];
try {
 if($method==='GET' && $path==='/health') json_response(200,['ok'=>true,'service'=>'parse-api']);
 if($method==='POST' && $path==='/auth/register'){
   $username=trim((string)($data['username']??''));$phone=trim((string)($data['phone']??''));$name=trim((string)($data['name']??''));$password=(string)($data['password']??'');
   if($username===''||$password===''||strlen($password)<8) json_response(422,['message'=>'نام کاربری و رمز عبور حداقل ۸ کاراکتری الزامی است']);
   if($phone!=='' && !preg_match('/^09\d{9}$/',$phone)) json_response(422,['message'=>'شماره موبایل معتبر نیست']);
   $s=$pdo->prepare('SELECT id FROM users WHERE username=? OR (phone<>"" AND phone=?) LIMIT 1');$s->execute([$username,$phone]);if($s->fetch())json_response(409,['message'=>'کاربر قبلاً ثبت شده است']);
   $s=$pdo->prepare('INSERT INTO users(username,phone,password_hash,name,role) VALUES(?,?,?,?,?)');$s->execute([$username,$phone?:null,password_hash($password,PASSWORD_DEFAULT),$name,'student']);
   $id=(int)$pdo->lastInsertId();$token=issue_token($pdo,$id);json_response(201,['token'=>$token,'user'=>['id'=>$id,'username'=>$username,'phone'=>$phone,'name'=>$name,'role'=>'student']]);
 }
 if($method==='POST' && $path==='/auth/login'){
   $login=trim((string)($data['username']??''));$password=(string)($data['password']??'');
   if($login===''||$password==='')json_response(422,['message'=>'نام کاربری و رمز عبور الزامی است']);
   $stmt=$pdo->prepare('SELECT id,username,phone,password_hash,name,role FROM users WHERE username=? OR phone=? LIMIT 1');$stmt->execute([$login,$login]);$user=$stmt->fetch();
   if(!$user||!password_verify($password,$user['password_hash']))json_response(401,['message'=>'اطلاعات ورود صحیح نیست']);
   unset($user['password_hash']);$token=issue_token($pdo,(int)$user['id']);json_response(200,['token'=>$token,'user'=>$user]);
 }
 if($method==='GET' && $path==='/auth/me')json_response(200,['user'=>require_user($pdo)]);
 if($method==='POST' && $path==='/auth/logout'){
   $token=bearer_token();if(!$token)json_response(401,['message'=>'نشست معتبر نیست']);$pdo->prepare('DELETE FROM auth_tokens WHERE token_hash=?')->execute([hash('sha256',$token)]);json_response(200,['message'=>'خروج انجام شد']);
 }
 json_response(404,['message'=>'مسیر یافت نشد']);
} catch(PDOException $e){
 if(envv('APP_ENV','production')==='development')json_response(500,['message'=>'Database error','detail'=>$e->getMessage()]);
 json_response(500,['message'=>'خطای داخلی سرور']);
} catch(Throwable $e){json_response(500,['message'=>'خطای داخلی سرور']);}

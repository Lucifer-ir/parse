<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // Restrict origins for production.
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
if ($_SERVER['REQUEST_METHOD']==='OPTIONS') { http_response_code(204); exit; }
$path=parse_url($_SERVER['REQUEST_URI']??'/',PHP_URL_PATH);
$path=preg_replace('#^/api#','',$path);
if ($path==='/auth/login' && $_SERVER['REQUEST_METHOD']==='POST') {
  require __DIR__.'/../src/bootstrap.php';
  $data=json_decode(file_get_contents('php://input'),true) ?? [];
  $username=trim((string)($data['username']??''));
  $password=(string)($data['password']??'');
  if($username===''||$password===''){http_response_code(422);echo json_encode(['message'=>'نام کاربری و رمز عبور الزامی است']);exit;}
  $stmt=$pdo->prepare('SELECT id, username, password_hash, name, role FROM users WHERE username=? OR phone=? LIMIT 1');
  $stmt->execute([$username,$username]); $user=$stmt->fetch(PDO::FETCH_ASSOC);
  if(!$user || !password_verify($password,$user['password_hash'])) {http_response_code(401);echo json_encode(['message'=>'اطلاعات ورود صحیح نیست']);exit;}
  $token=bin2hex(random_bytes(32)); $hash=hash('sha256',$token);
  $save=$pdo->prepare('INSERT INTO auth_tokens (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 30 DAY))');
  $save->execute([$user['id'],$hash]); unset($user['password_hash']);
  echo json_encode(['token'=>$token,'user'=>$user],JSON_UNESCAPED_UNICODE);exit;
}
http_response_code(404);echo json_encode(['message'=>'مسیر یافت نشد']);

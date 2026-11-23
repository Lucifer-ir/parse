<?php
declare(strict_types=1);
function bearer_token(): ?string {
 $header=$_SERVER['HTTP_AUTHORIZATION']??'';
 if(!preg_match('/^Bearer\s+([a-f0-9]{64})$/i',$header,$m)) return null;
 return $m[1];
}
function current_user(PDO $pdo): ?array {
 $token=bearer_token(); if(!$token) return null;
 $stmt=$pdo->prepare('SELECT u.id,u.username,u.phone,u.name,u.role FROM auth_tokens t JOIN users u ON u.id=t.user_id WHERE t.token_hash=? AND t.expires_at>UTC_TIMESTAMP() LIMIT 1');
 $stmt->execute([hash('sha256',$token)]); return $stmt->fetch() ?: null;
}
function require_user(PDO $pdo): array {
 $u=current_user($pdo); if(!$u) json_response(401,['message'=>'نشست معتبر نیست']); return $u;
}
function issue_token(PDO $pdo, int $userId): string {
 $token=bin2hex(random_bytes(32));
 $pdo->prepare('INSERT INTO auth_tokens(user_id,token_hash,expires_at) VALUES(?,?,DATE_ADD(UTC_TIMESTAMP(),INTERVAL 30 DAY))')->execute([$userId,hash('sha256',$token)]);
 return $token;
}

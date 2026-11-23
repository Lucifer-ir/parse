<?php
declare(strict_types=1);

function load_env_file(string $file): void {
    if (!is_file($file)) return;
    foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line=trim($line);
        if ($line==='' || str_starts_with($line,'#') || !str_contains($line,'=')) continue;
        [$key,$value]=explode('=',$line,2); $key=trim($key); $value=trim($value);
        if ($value!=='' && (($value[0]==='"' && str_ends_with($value,'"')) || ($value[0]==="'" && str_ends_with($value,"'")))) $value=substr($value,1,-1);
        if (getenv($key)===false) putenv("$key=$value");
    }
}
load_env_file(dirname(__DIR__). '/.env');
function envv(string $key, string $default=''): string { $v=getenv($key); return $v===false ? $default : $v; }
function json_response(int $status, array $payload): never {
    http_response_code($status); echo json_encode($payload,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES); exit;
}
$dsn='mysql:host='.envv('DB_HOST','127.0.0.1').';port='.envv('DB_PORT','3306').';dbname='.envv('DB_NAME','parse').';charset=utf8mb4';
$pdo=new PDO($dsn,envv('DB_USER'),envv('DB_PASSWORD'),[
 PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,
 PDO::ATTR_EMULATE_PREPARES=>false,
]);

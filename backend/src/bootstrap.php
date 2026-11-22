<?php
declare(strict_types=1);
function envv(string $key, string $default=''): string { return getenv($key) ?: $default; }
$pdo=new PDO('mysql:host='.envv('DB_HOST','127.0.0.1').';dbname='.envv('DB_NAME','parse').';charset=utf8mb4',envv('DB_USER'),envv('DB_PASSWORD'),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);

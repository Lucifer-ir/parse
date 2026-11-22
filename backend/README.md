# Parse Backend and Admin foundation

This directory is the PHP backend scaffold. It expects PHP 8.2+, PDO MySQL, HTTPS and a web server configured to route API requests to public/index.php.

## Setup
1. Copy .env.example to .env and fill database values, APP_SECRET and public URL.
2. Create the database and import database/schema.sql.
3. Point the web root to backend/public (do not expose config, SQL, or .env).
4. Configure Firebase Admin SDK credentials outside Git.
5. Configure AI provider key/model in the admin settings. Never ship provider keys in Flutter.

Implemented starter endpoint: POST /api/auth/login. Registration, content, exams, listening, speaking, AI question generation, notification administration and role-based admin workflows are API contracts to be implemented in subsequent work. The admin page is a protected-development placeholder, not production-ready.

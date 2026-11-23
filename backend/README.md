# Parse API foundation

PHP 8.2+ / MySQL starter. This stage deliberately leaves Flutter UI widgets, layouts, spacing, colors, navigation and typography unchanged.

## Deploy
- Use PHP 8.2+, PDO MySQL, HTTPS.
- Create database and import `database/schema.sql`.
- Copy `.env.example` to `.env` and fill DB credentials and comma-separated CORS origins.
- Set web root to `public/`. Do not expose this directory's parent.
- Verify `GET /api/health`.

## Routes
- `POST /api/auth/register`: username, optional phone, name, password (8+ characters); creates student.
- `POST /api/auth/login`: username or phone + password; returns bearer token.
- `GET /api/auth/me`: bearer token required.
- `POST /api/auth/logout`: revokes bearer token.

Tokens are random 256-bit values; only SHA-256 hashes are stored. PDO prepared statements and password_hash/password_verify are used. Error details are only exposed in development. Restrict CORS origins. Add throttling, email/phone verification, password reset, admin role provisioning, monitoring and security review before production.

## Flutter
Configure API endpoint at build time with `--dart-define=PARSE_API_URL=https://api.example.com/api`. UI work is intentionally not included in this foundation commit.

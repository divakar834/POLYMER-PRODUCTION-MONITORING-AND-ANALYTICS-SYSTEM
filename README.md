# Polymer Production Monitoring & Analytics System

A local operations platform for polymer manufacturers. The application combines production batches, inventory, material consumption, quality checks, machine status, analytics, and alerts in one role based workspace.

## Technology

- React and TypeScript with Vite
- Node.js and Express REST API
- MongoDB with Mongoose for operational data
- Redis for dashboard and report caching
- Docker Compose configuration for local deployment (can be used later)

## Accounts and roles

Four demo accounts are available from the sign in screen:

| Role | Email | Password |
|---|---|---|
| Administrator | `admin@polymer.com` | `Admin@123` |
| Production | `prod@polymer.com` | `Prod@123` |
| Quality | `quality@polymer.com` | `Quality@123` |
| Inventory | `inventory@polymer.com` | `Inventory@123` |

An administrator can create additional accounts and load any missing sample records from **Team access**. Loading sample data only inserts missing IDs; it keeps existing records and edits intact.

Admins have full access. Production, quality and inventory accounts are restricted to their respective work areas. Open **Data & imports** as an administrator to view MongoDB collection counts or upload an Excel workbook. Download the multi-sheet template, add rows under matching worksheet tabs, select the `.xlsx` file, review the row counts and import. Existing IDs are skipped so imports do not overwrite records. User accounts and role definitions cannot be imported.

## Local development

Prerequisites: Node.js 20+, MongoDB running on `mongodb://127.0.0.1:27017`, and Redis (optional; the API continues without cache if Redis is unavailable).

1. Copy `.env.example` to `.env`; set `JWT_SECRET` to a random value of at least 32 characters.
2. Install dependencies and load the sample dataset into MongoDB:

```sh
cd server
npm install
npm run db:setup
```

3. Start the API:

```sh
npm run dev
```

4. In a second terminal, start the client:

```sh
cd client
npm install
npm run dev
```

The app runs at http://localhost:3000 and the API at http://localhost:5000/api. The server also inserts missing sample records at startup, so a separate seed command is optional after initial setup.

## Docker (optional for later)

The compose file now describes MongoDB, Redis, the API, and client. Once ready to run the stack, set a private `JWT_SECRET` in `.env` and use:

```sh
docker compose up --build
```

## Sample dataset

The original PostgreSQL sample records were exported to `database/seed.json` and are loaded into MongoDB with stable IDs. The source SQL files are retained under `database/legacy-postgresql/` for reference. The **Load sample dataset** action is restricted to administrators.

## Environment and API

`.env.example` documents `MONGODB_URI`, `REDIS_URL`, `JWT_SECRET`, and `CLIENT_URL`. Operational endpoints except login require `Authorization: Bearer <token>`.

| Area | Endpoints |
|---|---|
| Session | `POST /api/auth/login`, `GET /api/auth/me`, admin registration |
| Team | `GET /api/users`, `POST /api/users`, admin only |
| Sample data | `POST /api/setup/sample-data`, admin only |
| Production | `/api/batches` |
| Inventory | `/api/materials` |
| Quality | `/api/quality` |
| Analytics | `/api/analytics/dashboard`, `/api/analytics/production`, `/quality`, `/inventory`, `/machines` |

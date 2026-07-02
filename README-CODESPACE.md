Quick start for Codespaces / Devcontainer

1. Start the devcontainer (or GitHub Codespace). The container will bring up Postgres via docker-compose.

2. From the `backend/server-nest` folder run:

```bash
npm install
npx prisma generate
npm run start:dev
```

3. Apply SQL migration files to the Postgres instance (connect to localhost:5432).

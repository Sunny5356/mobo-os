NestJS backend scaffold (minimal).

This is a lightweight stub showing where to wire tenant-context/session var logic.

Run (after installing deps):

```
cd backend/server-nest
npm install
npm run start:dev
```

NOTE: This scaffold does not include a database client. Integrate Prisma or pg client and set
`app.current_tenant_id` on the connection/transaction before executing queries to enforce RLS.

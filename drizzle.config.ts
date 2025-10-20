import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './server/shared/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  verbose: true,
  strict: true,
});

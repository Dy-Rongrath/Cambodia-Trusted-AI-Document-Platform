import { defineConfig } from 'prisma/config';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    // `prisma generate` does not require a live database connection.
    url: process.env['DATABASE_URL'] ?? '',
  },
});

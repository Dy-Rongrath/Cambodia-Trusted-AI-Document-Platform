import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';

async function main() {
  let prisma: PrismaClient | undefined;

  try {
    const connectionString = process.env['DATABASE_URL'];
    if (!connectionString) {
      throw new Error('DATABASE_URL is required for the database connectivity check');
    }

    const adapter = new PrismaPg({ connectionString });
    prisma = new PrismaClient({ adapter });
    const result = await prisma.$queryRaw`SELECT 1 as result`;
    console.log('Database connectivity check succeeded:', result);
  } catch (error) {
    console.error('Database connectivity check failed:', error);
    process.exitCode = 1;
  } finally {
    await prisma?.$disconnect();
  }
}

void main();

import { PrismaClient } from '@prisma/client';

async function main() {
  const prisma = new PrismaClient();
  try {
    const result = await prisma.$queryRaw`SELECT 1 as result`;
    console.log('Database connectivity check succeeded:', result);
  } catch (error) {
    console.error('Database connectivity check failed:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

void main();

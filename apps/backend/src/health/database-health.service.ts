import { Inject, Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';

import { Pool } from 'pg';

export const DATABASE_HEALTH_CLIENT = Symbol('DATABASE_HEALTH_CLIENT');

export type DatabaseHealthClient = Pick<PrismaClient, '$queryRaw' | '$disconnect'> & {
  _pool?: Pool;
};

export function createDatabaseHealthClient(): DatabaseHealthClient | null {
  const connectionString = process.env['DATABASE_URL'];
  if (!connectionString) {
    return null;
  }

  const pool = new Pool({
    connectionString,
    connectionTimeoutMillis: 2_000,
    query_timeout: 2_000,
  });

  const adapter = new PrismaPg(pool);
  const client = new PrismaClient({ adapter }) as DatabaseHealthClient;
  client._pool = pool;

  return client;
}

@Injectable()
export class DatabaseHealthService implements OnModuleDestroy {
  private readonly logger = new Logger(DatabaseHealthService.name);

  constructor(
    @Inject(DATABASE_HEALTH_CLIENT)
    private readonly client: DatabaseHealthClient | null,
  ) {}

  async isReady(): Promise<boolean> {
    if (!this.client) {
      this.logger.warn({
        event: 'postgres_readiness_failed',
        reason: 'database_url_missing',
      });
      return false;
    }

    try {
      await this.client.$queryRaw`SELECT 1`;
      return true;
    } catch (error) {
      this.logger.warn({
        event: 'postgres_readiness_failed',
        errorType: error instanceof Error ? error.name : 'unknown',
      });
      return false;
    }
  }

  async onModuleDestroy(): Promise<void> {
    await this.client?.$disconnect();
    await this.client?._pool?.end();
  }
}

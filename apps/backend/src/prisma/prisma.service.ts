import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';

/**
 * Shared PrismaService — Phase 1 stub.
 *
 * Provides a single, lifecycle-managed PrismaClient instance for the entire
 * application. Business modules introduced from Phase 3 onward must inject
 * this service rather than constructing their own PrismaClient instances.
 *
 * The driver-adapter pattern (PrismaPg) is used for all connections, matching
 * the approach established in DatabaseHealthService.
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    const connectionString = process.env['DATABASE_URL'];

    if (!connectionString) {
      throw new Error('DATABASE_URL environment variable is required');
    }

    const adapter = new PrismaPg({ connectionString });
    super({ adapter });
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.log({ event: 'prisma_connected' });
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
    this.logger.log({ event: 'prisma_disconnected' });
  }
}

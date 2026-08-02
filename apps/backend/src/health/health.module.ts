import { Module } from '@nestjs/common';
import {
  createDatabaseHealthClient,
  DATABASE_HEALTH_CLIENT,
  DatabaseHealthService,
} from './database-health.service';
import { HealthController } from './health.controller';

@Module({
  controllers: [HealthController],
  providers: [
    DatabaseHealthService,
    {
      provide: DATABASE_HEALTH_CLIENT,
      useFactory: createDatabaseHealthClient,
    },
  ],
})
export class HealthModule {}

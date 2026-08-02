import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import type { HealthResponse, ReadinessResponse } from '@trusted-ai/shared-types';
import { DatabaseHealthService } from './database-health.service';

@Controller('health')
export class HealthController {
  constructor(private readonly databaseHealthService: DatabaseHealthService) {}

  @Get()
  getHealth(): HealthResponse {
    return this.getLiveness();
  }

  @Get('live')
  getLiveness(): HealthResponse {
    return {
      status: 'ok',
      service: 'backend',
    };
  }

  @Get('ready')
  async getReadiness(): Promise<ReadinessResponse> {
    const postgresReady = await this.databaseHealthService.isReady();
    const response: ReadinessResponse = {
      status: postgresReady ? 'ok' : 'unavailable',
      service: 'backend',
      dependencies: {
        postgres: postgresReady ? 'ok' : 'unavailable',
      },
    };

    if (!postgresReady) {
      throw new ServiceUnavailableException(response);
    }

    return response;
  }
}

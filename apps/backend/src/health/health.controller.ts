import { Controller, Get } from '@nestjs/common';
import { HealthResponse } from '@trusted-ai/shared-types';

@Controller('health')
export class HealthController {
  @Get()
  getHealth(): HealthResponse {
    return {
      status: 'ok',
      service: 'backend',
    };
  }
}

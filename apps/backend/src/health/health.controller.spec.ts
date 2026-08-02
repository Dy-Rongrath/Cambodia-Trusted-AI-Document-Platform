import { ServiceUnavailableException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { DatabaseHealthService } from './database-health.service';
import { HealthController } from './health.controller';

describe('HealthController', () => {
  let controller: HealthController;
  const databaseHealthService = {
    isReady: jest.fn(),
  };

  beforeEach(async () => {
    databaseHealthService.isReady.mockReset();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: DatabaseHealthService,
          useValue: databaseHealthService,
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return health status', () => {
    expect(controller.getHealth()).toEqual({
      status: 'ok',
      service: 'backend',
    });
  });

  it('should return liveness without checking PostgreSQL', () => {
    expect(controller.getLiveness()).toEqual({
      status: 'ok',
      service: 'backend',
    });
    expect(databaseHealthService.isReady).not.toHaveBeenCalled();
  });

  it('should return readiness when PostgreSQL is available', async () => {
    databaseHealthService.isReady.mockResolvedValue(true);

    await expect(controller.getReadiness()).resolves.toEqual({
      status: 'ok',
      service: 'backend',
      dependencies: {
        postgres: 'ok',
      },
    });
  });

  it('should return 503 readiness when PostgreSQL is unavailable', async () => {
    databaseHealthService.isReady.mockResolvedValue(false);

    try {
      await controller.getReadiness();
      fail('Expected readiness to throw');
    } catch (error) {
      expect(error).toBeInstanceOf(ServiceUnavailableException);
      expect((error as ServiceUnavailableException).getStatus()).toBe(503);
      expect((error as ServiceUnavailableException).getResponse()).toEqual({
        status: 'unavailable',
        service: 'backend',
        dependencies: {
          postgres: 'unavailable',
        },
      });
    }
  });
});

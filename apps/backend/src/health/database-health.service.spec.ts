import { Logger } from '@nestjs/common';
import type { DatabaseHealthClient } from './database-health.service';
import { DatabaseHealthService } from './database-health.service';

describe('DatabaseHealthService', () => {
  const createClient = () => ({
    $queryRaw: jest.fn(),
    $disconnect: jest.fn(),
  });

  it('reports ready after PostgreSQL responds', async () => {
    const client = createClient();
    client.$queryRaw.mockResolvedValue([{ result: 1 }]);
    const service = new DatabaseHealthService(client as unknown as DatabaseHealthClient);

    await expect(service.isReady()).resolves.toBe(true);
    expect(client.$queryRaw).toHaveBeenCalledTimes(1);
  });

  it('reports unavailable without logging sensitive error details', async () => {
    const client = createClient();
    client.$queryRaw.mockRejectedValue(new Error('sensitive connection details'));
    const warn = jest.spyOn(Logger.prototype, 'warn').mockImplementation();
    const service = new DatabaseHealthService(client as unknown as DatabaseHealthClient);

    await expect(service.isReady()).resolves.toBe(false);
    expect(warn).toHaveBeenCalledWith({
      event: 'postgres_readiness_failed',
      errorType: 'Error',
    });

    warn.mockRestore();
  });

  it('reports unavailable when DATABASE_URL was not configured', async () => {
    const warn = jest.spyOn(Logger.prototype, 'warn').mockImplementation();
    const service = new DatabaseHealthService(null);

    await expect(service.isReady()).resolves.toBe(false);
    expect(warn).toHaveBeenCalledWith({
      event: 'postgres_readiness_failed',
      reason: 'database_url_missing',
    });

    warn.mockRestore();
  });

  it('disconnects the readiness client during shutdown', async () => {
    const client = createClient();
    client.$disconnect.mockResolvedValue(undefined);
    const service = new DatabaseHealthService(client as unknown as DatabaseHealthClient);

    await service.onModuleDestroy();

    expect(client.$disconnect).toHaveBeenCalledTimes(1);
  });
});

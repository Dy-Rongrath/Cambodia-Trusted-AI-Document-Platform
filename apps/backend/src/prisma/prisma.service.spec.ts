import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from './prisma.service';

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(async () => {
    // Provide a fake DATABASE_URL so the constructor does not throw.
    process.env['DATABASE_URL'] = 'postgresql://user:pass@localhost:5432/testdb';

    const module: TestingModule = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    service = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    delete process.env['DATABASE_URL'];
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should throw when DATABASE_URL is missing', () => {
    delete process.env['DATABASE_URL'];
    expect(() => new PrismaService()).toThrow('DATABASE_URL environment variable is required');
  });
});

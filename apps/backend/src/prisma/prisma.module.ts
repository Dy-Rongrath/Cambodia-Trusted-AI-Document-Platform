import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

/**
 * PrismaModule — Phase 1 stub.
 *
 * Marked @Global so that PrismaService is available application-wide
 * without re-importing this module in every feature module. Business
 * modules from Phase 3 onward inject PrismaService directly.
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}

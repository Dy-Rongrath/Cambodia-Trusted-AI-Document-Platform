import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('Bootstrap');

  // ---------------------------------------------------------------------------
  // TODO (Phase 3): Uncomment and configure the following hardening middleware
  // before introducing any authenticated endpoint. Each item is required by
  // AGENTS.md §4 and SECURITY.md before external HTTP input is accepted.
  // ---------------------------------------------------------------------------
  //
  // import { ValidationPipe } from '@nestjs/common';
  // app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  //
  // import helmet from 'helmet';
  // app.use(helmet());                       // HTTP security headers
  //
  // app.enableCors({ origin: false });       // Tighten per Phase 3 origin list
  //
  // app.setGlobalPrefix('api');              // Consistent API prefix for versioning
  // ---------------------------------------------------------------------------

  const port = process.env['PORT'] ? parseInt(process.env['PORT'], 10) : 3000;
  await app.listen(port);
  logger.log(`Application listening on port ${port.toString()}`);
}
void bootstrap();

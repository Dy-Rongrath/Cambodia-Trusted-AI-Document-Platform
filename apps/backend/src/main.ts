import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('Bootstrap');


  const port = process.env['PORT'] ? parseInt(process.env['PORT'], 10) : 3000;
  await app.listen(port);
  logger.log(`Application listening on port ${port.toString()}`);
}
void bootstrap();

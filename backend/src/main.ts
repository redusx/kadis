import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { NextFunction, Request, Response } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  app.useGlobalInterceptors(new TransformInterceptor());

  app.useGlobalFilters(new HttpExceptionFilter());

  app.enableCors();

  // Swagger API Documentation
  const config = new DocumentBuilder()
    .setTitle('KADIS API')
    .setDescription('Kan Bağışı Sistemi API Dokümantasyonu')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  // Request Logger Middleware
  app.use((req: Request, res: Response, next: NextFunction) => {
    const start = Date.now();
    console.log(`📥 ${req.method} ${req.url}`);
    const body = req.body as Record<string, unknown> | undefined;
    if (body && Object.keys(body).length > 0) {
      console.log('   Body:', JSON.stringify(body));
    }

    res.on('finish', () => {
      const duration = Date.now() - start;
      const status = res.statusCode;
      const emoji = status >= 400 ? '❌' : '✅';
      console.log(
        `${emoji} ${req.method} ${req.url} - ${status} (${duration}ms)`,
      );
    });

    next();
  });

  await app.listen(3000);
  console.log('🚀 KADIS Backend is running on http://localhost:3000');
  console.log('📚 Swagger UI: http://localhost:3000/api');
}
void bootstrap();

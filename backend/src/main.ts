import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

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
  app.use((req: any, res: any, next: any) => {
    const start = Date.now();
    console.log(`📥 ${req.method} ${req.url}`);
    if (req.body && Object.keys(req.body).length > 0) {
      console.log('   Body:', JSON.stringify(req.body));
    }

    res.on('finish', () => {
      const duration = Date.now() - start;
      const status = res.statusCode;
      const emoji = status >= 400 ? '❌' : '✅';
      console.log(`${emoji} ${req.method} ${req.url} - ${status} (${duration}ms)`);
    });

    next();
  });

  await app.listen(3000);
  console.log('🚀 KADIS Backend is running on http://localhost:3000');
  console.log('📚 Swagger UI: http://localhost:3000/api');
}
bootstrap();

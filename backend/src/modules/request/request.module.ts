// src/modules/request/request.module.ts
import { Module } from '@nestjs/common';
import { RequestService } from './request.service'; // Adı create ettiğinde request.service olmuş olabilir
import { RequestController } from './request.controller';
import { DatabaseModule } from '../../core/database/database.module'; // Yolu kontrol et

@Module({
  imports: [DatabaseModule], // <-- KRİTİK HAMLE
  controllers: [RequestController],
  providers: [RequestService],
})
export class RequestModule {}

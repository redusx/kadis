import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private prisma = new PrismaClient({
    log: ['info', 'warn', 'error'],
  });

  async onModuleInit() {
    await this.prisma.$connect();
  }

  async onModuleDestroy() {
    await this.prisma.$disconnect();
  }

  get client() {
    return this.prisma;
  }
}

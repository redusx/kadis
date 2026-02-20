import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { DatabaseModule } from '../../core/database/database.module';
import { AuthGuard } from '../auth/auth.guard';

@Module({
  imports: [DatabaseModule],
  controllers: [UserController],
  providers: [UserService, AuthGuard],
  exports: [UserService],
})
export class UserModule { }

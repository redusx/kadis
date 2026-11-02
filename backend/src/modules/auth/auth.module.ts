import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from '../user/user.module';
import { JwtModule } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

@Module({
  imports: [
    UserModule,//bunun için user.module import ettik


    //JWT Configuration
    JwtModule.registerAsync({//bunun için jwtModule import ettik
      global: true,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.getOrThrow<string>('JWT_SECRET'),//.env dosyasından okunuyor
        signOptions: { expiresIn: '15d' },
      }),
    }),
  ],

  controllers: [AuthController],
  providers: [AuthService],
  exports:[AuthService] //Bu exportu ekledik
})
export class AuthModule {}


// JWT + Service + Controller
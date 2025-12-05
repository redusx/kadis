import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from 'src/user/user.module';
import { JwtModule } from '@nestjs/jwt';
import { jwtConstants } from './constants';

@Module({
  imports: [
    UserModule,//bunun için user.module import ettik


    //JWT Configuration
    JwtModule.register({//bunun için jwtModule import ettik
      global: true,
      secret: jwtConstants.secret,//constants.ts'i import edip oradaki ifadeyi kullanıyoruz
      signOptions: { expiresIn: '15d' },
    }),
  ],

  controllers: [AuthController],
  providers: [AuthService],
  exports:[AuthService] //Bu exportu ekledik
})
export class AuthModule {}


// JWT + Service + Controller
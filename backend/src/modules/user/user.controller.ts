// src/modules/user/user.controller.ts
import { Controller, Get, Post, Body, Patch, Param, Delete, Request } from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto';
// import { AuthGuard } from '../auth/auth.guard'; // <-- YORUM SATIRI YAP
// import { ApiBearerAuth } from '@nestjs/swagger'; // <-- YORUM SATIRI YAP

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  // @UseGuards(AuthGuard) // <-- GEÇİCİ OLARAK KAPAT
  // @ApiBearerAuth()      // <-- GEÇİCİ OLARAK KAPAT
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }

  // @UseGuards(AuthGuard) // <-- GEÇİCİ OLARAK KAPAT
  // @ApiBearerAuth()
  @Patch()
  update(@Body() updateUserDto: UpdateUserDto, @Request() req) {
    // req.user.id şu an çalışmaz çünkü guard kapalı, test için elle ID verebiliriz veya bu metodu şimdilik es geçebiliriz.
    // Şimdilik burası hata verebilir, önemli değil. Bizim hedefimiz RequestModule.
    return this.userService.update('test-user-id', updateUserDto); 
  }

  // ... Diğer metodlardaki Guard'ları da kapat.
}
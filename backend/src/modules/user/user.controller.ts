// src/modules/user/user.controller.ts
import {
  Controller,
  Get,
  Patch,
  Body,
  Request,
  UseGuards,
} from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { AuthGuard } from '../auth/auth.guard';
import type { AuthenticatedRequest } from '../auth/auth.guard';
import { ApiBearerAuth } from '@nestjs/swagger';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @UseGuards(AuthGuard)
  @ApiBearerAuth()
  @Get('profile')
  getProfile(@Request() req: AuthenticatedRequest) {
    // req.user AuthGuard tarafından set ediliyor (findOneById ile DonorProfile dahil)
    return req.user;
  }

  @UseGuards(AuthGuard)
  @ApiBearerAuth()
  @Patch()
  update(
    @Body() updateUserDto: UpdateUserDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.userService.update(req.user.id, updateUserDto);
  }
}

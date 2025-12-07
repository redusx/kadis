import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, ValidationPipe } from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from 'src/auth/auth.guard';
import { ApiBearerAuth } from '@nestjs/swagger';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @UseGuards(AuthGuard)
  @ApiBearerAuth()
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }

  @UseGuards(AuthGuard)
  @ApiBearerAuth()
  @Patch()
  update(@Body() updateUserDto: UpdateUserDto, @Request() req) {
    return this.userService.update(req.user.id, updateUserDto);
  }

  @UseGuards(AuthGuard)
  @ApiBearerAuth()
  @Patch('patch/:id')
  patch(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.patch(id, updateUserDto);
  }

  @Get()
  @ApiResponse({ status: 200, description: 'List of all users.' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  findAll() {
    return this.userService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userService.findOneById(id);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.userService.remove(id);
  }
}

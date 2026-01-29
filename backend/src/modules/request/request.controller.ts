import {
  Controller,
  Post,
  Body,
  Get,
  Query,
  Param,
  ParseFloatPipe,
} from '@nestjs/common';
import { RequestService } from './request.service';
import { CreateBloodRequestDto } from './dto/create-blood-request.dto';
import { AcceptRequestDto } from './dto/accept-request.dto';

@Controller('request')
export class RequestController {
  constructor(private readonly requestService: RequestService) {}

  @Post()
  async create(@Body() createDto: CreateBloodRequestDto) {
    return this.requestService.create(createDto);
  }

  @Get('nearby')
  async findNearby(
    @Query('lat', ParseFloatPipe) lat: number,
    @Query('lon', ParseFloatPipe) lon: number,
  ) {
    return this.requestService.findNearbyRequests(lat, lon);
  }

  @Post(':id/report')
  async reportDonation(
    @Param('id') id: string,
    @Body('donorId') donorId: string,
  ) {
    return this.requestService.reportDonation(id, donorId);
  }

  @Post(':id/confirm')
  async confirmDonation(
    @Param('id') id: string,
    @Body('requesterId') requesterId: string,
  ) {
    return this.requestService.confirmDonation(id, requesterId);
  }

  @Post(':id/accept')
  async accept(@Param('id') id: string, @Body() acceptDto: AcceptRequestDto) {
    return this.requestService.acceptRequest(id, acceptDto.donorId);
  }

  @Get('profile/:userId')
  async getProfile(@Param('userId') userId: string) {
    return this.requestService.getDonorProfile(userId);
  }

  @Get()
  async findAll() {
    return this.requestService.findAll();
  }
}

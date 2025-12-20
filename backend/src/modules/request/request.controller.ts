import { Controller, Post, Body, Get } from '@nestjs/common';
import { RequestService } from './request.service';
import { CreateBloodRequestDto } from './dto/create-blood-request.dto'; // <-- Yeni dosyayı import et

@Controller('request')
export class RequestController {
  constructor(private readonly requestService: RequestService) {}

  @Post()
  async create(@Body() createDto: CreateBloodRequestDto) {
    return this.requestService.create(createDto);
  }

  @Get()
  async findAll() {
    return this.requestService.findAll();
  }
}

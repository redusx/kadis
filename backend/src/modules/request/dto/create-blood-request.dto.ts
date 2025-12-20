// src/modules/request/dto/create-blood-request.dto.ts
import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsEnum,
  IsUUID,
  Min,
  Max,
} from 'class-validator';
import { BloodType, Urgency } from '@prisma/client';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBloodRequestDto {
  @ApiProperty({ example: 'manuel-test-id-1' })
  @IsString()
  @IsNotEmpty()
  requesterId: string;

  @ApiProperty({ example: 'Hacettepe Acil' })
  @IsString()
  @IsNotEmpty()
  hospitalName: string;

  @ApiProperty({ enum: BloodType, example: BloodType.A_RH_POS })
  @IsEnum(BloodType)
  bloodType: BloodType;

  @ApiProperty({ example: 2 })
  @IsNumber()
  @Min(1)
  unitsNeeded: number;

  @ApiProperty({ example: 39.92077 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ example: 32.85411 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiProperty({ enum: Urgency, example: Urgency.HIGH })
  @IsEnum(Urgency)
  urgency: Urgency;
}

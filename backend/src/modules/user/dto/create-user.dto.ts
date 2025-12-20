import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { IsPhoneNumber, IsString, MinLength, IsOptional, IsEnum } from 'class-validator';

export class CreateUserDto {
  @ApiProperty({ example: '5551234567' })
  @IsPhoneNumber('TR') // Assuming Turkish phone numbers, adjust if needed
  phoneNumber: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password: string;

  @ApiPropertyOptional({ enum: Role, example: Role.DONOR, default: Role.DONOR })
  @IsOptional()
  @IsEnum(Role)
  role?: Role; // Make role optional
}

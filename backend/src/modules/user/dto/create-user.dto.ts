import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Role, BloodType, Gender } from '@prisma/client';
import { IsPhoneNumber, IsString, MinLength, IsOptional, IsEnum, IsDateString, IsInt, Min } from 'class-validator';

export class CreateUserDto {
  @ApiProperty({ example: '5551234567' })
  @IsPhoneNumber('TR')
  phoneNumber: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password: string;

  @ApiPropertyOptional({ enum: Role, example: Role.DONOR, default: Role.DONOR })
  @IsOptional()
  @IsEnum(Role)
  role?: Role;

  // Donor Profile Fields (opsiyonel — kayıt sırasında gönderilebilir)
  @ApiPropertyOptional({ example: 'Ahmet' })
  @IsOptional()
  @IsString()
  firstName?: string;

  @ApiPropertyOptional({ example: 'Yılmaz' })
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiPropertyOptional({ enum: BloodType, example: BloodType.A_RH_POS })
  @IsOptional()
  @IsEnum(BloodType)
  bloodType?: BloodType;

  @ApiPropertyOptional({ enum: Gender, example: Gender.MALE })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

  @ApiPropertyOptional({ example: '1990-01-15' })
  @IsOptional()
  @IsDateString()
  birthDate?: string;

  @ApiPropertyOptional({ example: 75 })
  @IsOptional()
  @IsInt()
  @Min(30)
  weight?: number;
}

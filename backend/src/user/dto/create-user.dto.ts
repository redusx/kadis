import { ApiProperty } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { IsEnum, IsPhoneNumber, IsString, MinLength } from 'class-validator';


export class CreateUserDto {
  @ApiProperty({ example: '5551234567' })
  @IsPhoneNumber('TR')
  phoneNumber: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @MinLength(8)
  password: string;

  @ApiProperty({ enum: Role, example: Role.DONOR })
  @IsEnum(Role)
  role: Role;
}

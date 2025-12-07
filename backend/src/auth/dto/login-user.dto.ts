import { IsString, IsNotEmpty, IsPhoneNumber } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UserLoginDto {
  @ApiProperty({ example: '5551234567' })
  @IsPhoneNumber('TR')
  @IsNotEmpty()
  phoneNumber: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @IsNotEmpty()
  password: string;
}

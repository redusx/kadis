import { ApiProperty } from '@nestjs/swagger';
import { Role } from '@prisma/client';


export class CreateUserDto {
  @ApiProperty({ example: '5551234567' })
  phoneNumber: string;

  @ApiProperty({ example: 'password123' })
  password: string;

  @ApiProperty({ enum: Role, example: Role.DONOR })
  role: Role;
}

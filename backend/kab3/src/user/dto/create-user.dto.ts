import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';


export class CreateUserDto {
  @ApiProperty({ example: 'user@example.com' })
  email: string;

  @ApiProperty({ example: 'password123' })
  password_hash: string;

  @ApiProperty({ enum: UserRole, example: UserRole.DONOR })
  role: UserRole;
}

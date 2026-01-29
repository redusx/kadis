import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AcceptRequestDto {
  @ApiProperty({ example: 'manuel-test-id-1' })
  @IsString()
  @IsNotEmpty()
  donorId: string;
}

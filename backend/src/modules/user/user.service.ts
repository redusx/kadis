import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { DatabaseService } from '../../core/database/database.service';

@Injectable()
export class UserService {
  constructor(private readonly databaseService: DatabaseService) {}

  create(createUserDto: CreateUserDto) {
    return this.databaseService.user.create({
      data: { ...createUserDto },
    });
  }
  findAll() {
    return this.databaseService.user.findMany();
  }

  update(id: string, updateUserDto: UpdateUserDto) {
    return this.databaseService.user.update({
      where: {
        id: id,
      },
      data: {
        ...updateUserDto,
      },
    });
  }

  patch(id: string, updateUserDto: UpdateUserDto) {
    const data = Object.fromEntries(
      Object.entries(updateUserDto).filter(([_, v]) => v !== undefined),
    );

    return this.databaseService.user.update({
      where: {
        id,
      },
      data,
    });
  }

  remove(id: string) {
    return this.databaseService.user.delete({
      where: {
        id: id,
      },
    });
  }

  async findOneByPhoneNumber(phoneNumber: string): Promise<any> {
    return this.databaseService.user.findUnique({
      where: { phoneNumber: phoneNumber },
    });
  }

  async findOneById(id: string): Promise<any> {
    return this.databaseService.user.findUnique({
      where: { id: id },
      select: {
        id: true,
        phoneNumber: true,
        role: true,
      },
    });
  }
}

import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { DatabaseService } from 'src/database/database.service';

@Injectable()
export class UserService {
  constructor(private readonly databaseService : DatabaseService) {}
  create(createUserDto: CreateUserDto) {
    return this.databaseService.client.user.create({
      data:{
        ...createUserDto
      }
    });
  }

  findAll() {
    return this.databaseService.client.user.findMany();
  }

  update(id: string, updateUserDto: UpdateUserDto) {
    return this.databaseService.client.user.update({
      where:{
        id:id
      },
      data:{
        ...updateUserDto
      }
    });
  }

  patch(id: string, updateUserDto: UpdateUserDto) {
  const data = Object.fromEntries(
    Object.entries(updateUserDto).filter(([_, v]) => v !== undefined)
  );

  return this.databaseService.client.user.update({
    where: { 
      id 
    },
    data, 
  });
  }


  remove(id: string) {
    return this.databaseService.client.user.delete({
      where:{
        id:id
      }
    });
  }  

  async findOneLogin(idOrEmail: string): Promise<any> {
    const isEmail = idOrEmail.includes('@');

    return this.databaseService.client.user.findUnique({
      where: isEmail ? { email: idOrEmail } : { id: idOrEmail },
    });
  }

  async findOne(idOrEmail: string): Promise<any> {
    const isEmail = idOrEmail.includes('@'); 

    if (isEmail) {
      return this.databaseService.client.user.findUnique({
        where: { email: idOrEmail },
        select: {
          id: true,
          email: true,
          role: true,
        },
      });
    }
    return this.databaseService.client.user.findUnique({
      where: { id: idOrEmail },
      select: {
        id: true,
        email: true,
        role: true,
      },
    });
  }
}

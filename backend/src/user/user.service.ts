import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { DatabaseService } from 'src/database/database.service';

@Injectable()
export class UserService {
  constructor(private readonly databaseService : DatabaseService) {}
  create(createUserDto: CreateUserDto) {
    // The DTO is now correct, so the spread operator works.
    // We assume the password will be hashed in a future step (e.g., in the auth service)
    // before being passed to this create method.
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

  // This function is likely used for the login process to get the user's hashed password.
  // It should now find the user by their unique phone number.
  async findOneByPhoneNumber(phoneNumber: string): Promise<any> {
    return this.databaseService.client.user.findUnique({
      where: { phoneNumber: phoneNumber },
    });
  }

  // This function is for retrieving a user's public data, by their ID.
  async findOneById(id: string): Promise<any> {
    return this.databaseService.client.user.findUnique({
      where: { id: id },
      select: {
        id: true,
        phoneNumber: true, // Changed from email
        role: true,
      },
    });
  }
}

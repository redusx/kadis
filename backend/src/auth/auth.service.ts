import { CreateAuthDto } from './dto/create-auth.dto';
import { UpdateAuthDto } from './dto/update-auth.dto';
import {
ConflictException,
Injectable,
UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { UserService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt';
import { CreateUserDto } from 'src/user/dto/create-user.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  async signIn(email: string,pass: string,): Promise<{ access_token: string }> {
  const user = await this.userService.findOneLogin(email);

  if (!user || !(await bcrypt.compare(pass, user.password_hash))) {
    throw new UnauthorizedException('Invalid credentials');
  }
  if (user.isDeleted) {
    throw new UnauthorizedException('User is deleted');
  }
  const payload = { sub: user.id, email: user.email };
  return {access_token: await this.jwtService.signAsync(payload),} 
  }
  
  async signUp(createUserDto: CreateUserDto) {
    const existingUser = await this.userService.findOne(createUserDto.email);
    if (existingUser) {
      throw new ConflictException('Email already exists');
    }
    try {
      const hashedPassword = await bcrypt.hash(createUserDto.password_hash, 10);
      if (!hashedPassword) {
        throw new Error('Password hashing failed');
      }
      const newUserDto = {...createUserDto, password_hash: hashedPassword };
      const resp = await this.userService.create(newUserDto);
      if (resp) {
        return { message: 'User registered successfully' };
      } 
      else {
        throw new Error('User creation failed');
      }
    } catch (error) {
      throw new Error("Password hashing failed : " + error.message);
    }
  }

  async deleteProfile(userId: string) {
    return this.userService.remove(userId);
  }
  create(createAuthDto: CreateAuthDto) {
    return 'This action adds a new auth';
  }

  findAll() {
    return `This action returns all auth`;
  }

  findOne(id: number) {
    return `This action returns a #${id} auth`;
  }

  update(id: number, updateAuthDto: UpdateAuthDto) {
    return `This action updates a #${id} auth`;
  }

  remove(id: number) {
    return `This action removes a #${id} auth`;
  }
}

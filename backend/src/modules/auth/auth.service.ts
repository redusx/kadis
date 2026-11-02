import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { UserService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt';
import { CreateUserDto } from '../user/dto/create-user.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  async signIn(
    phoneNumber: string,
    pass: string,
  ): Promise<{ access_token: string; userId: string }> {
    const user = await this.userService.findOneByPhoneNumber(phoneNumber);

    if (!user || !(await bcrypt.compare(pass, user.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = {
      sub: user.id,
      phoneNumber: user.phoneNumber,
    };

    return {
      access_token: await this.jwtService.signAsync(payload),
      userId: user.id,
    };
  }

  async signUp(createUserDto: CreateUserDto) {
    const existingUser = await this.userService.findOneByPhoneNumber(
      createUserDto.phoneNumber,
    );
    if (existingUser) {
      throw new ConflictException('Phone number already exists');
    }
    try {
      const hashedPassword = await bcrypt.hash(createUserDto.password, 10);
      if (!hashedPassword) {
        throw new Error('Password hashing failed');
      }

      // Donor profile alanlarını ve adres alanlarını ayır
      const {
        firstName,
        lastName,
        bloodType,
        gender,
        birthDate,
        weight,
        email,
        city,
        town,
        quarter,
        street,
        latitude,
        longitude,
        ...userData
      } = createUserDto;
      const newUserDto = { ...userData, password: hashedPassword, email };

      const resp = await this.userService.createWithProfile(newUserDto, {
        firstName,
        lastName,
        bloodType,
        gender,
        birthDate,
        weight,
        city,
        town,
        quarter,
        street,
        latitude,
        longitude,
      });

      if (resp) {
        return { message: 'User registered successfully' };
      } else {
        throw new Error('User creation failed');
      }
    } catch (error) {
      const reason = error instanceof Error ? error.message : String(error);
      throw new Error('User registration failed: ' + reason);
    }
  }

  async deleteProfile(userId: string) {
    return this.userService.remove(userId);
  }
}

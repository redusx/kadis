import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { DatabaseService } from '../../core/database/database.service';

@Injectable()
export class UserService {
  constructor(private readonly databaseService: DatabaseService) { }

  create(createUserDto: CreateUserDto) {
    return this.databaseService.user.create({
      data: { ...createUserDto },
    });
  }

  /**
   * User + DonorProfile oluşturma (signup sırasında)
   * Donor profil alanları varsa DonorProfile da oluşturulur
   */
  async createWithProfile(
    userData: { phoneNumber: string; password: string; role?: any },
    donorData: {
      firstName?: string;
      lastName?: string;
      bloodType?: any;
      gender?: any;
      birthDate?: string;
      weight?: number;
    },
  ) {
    // Donor profil alanları dolu mu kontrol et
    const hasDonorData = donorData.firstName && donorData.lastName && donorData.bloodType && donorData.gender && donorData.birthDate;

    if (hasDonorData) {
      // User + DonorProfile birlikte oluştur
      return this.databaseService.user.create({
        data: {
          phoneNumber: userData.phoneNumber,
          password: userData.password,
          role: userData.role || 'DONOR',
          donorProfile: {
            create: {
              firstName: donorData.firstName!,
              lastName: donorData.lastName!,
              bloodType: donorData.bloodType!,
              gender: donorData.gender!,
              birthDate: new Date(donorData.birthDate!),
              weight: donorData.weight || null,
            },
          },
        },
        include: {
          donorProfile: true,
        },
      });
    } else {
      // Sadece User oluştur (donor bilgileri eksikse)
      return this.databaseService.user.create({
        data: {
          phoneNumber: userData.phoneNumber,
          password: userData.password,
          role: userData.role || 'DONOR',
        },
      });
    }
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
        isVerified: true,
        kvkkConsent: true,
        createdAt: true,
        donorProfile: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            bloodType: true,
            gender: true,
            birthDate: true,
            weight: true,
            lastDonationDate: true,
            totalDonations: true,
            trustScore: true,
          },
        },
      },
    });
  }
}

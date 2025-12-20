// src/modules/request/request.service.ts
import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../core/database/database.service';
import { CreateBloodRequestDto } from './dto/create-blood-request.dto';
import { BloodType } from '@prisma/client';

@Injectable()
export class RequestService {
  constructor(private readonly database: DatabaseService) {}

  async create(dto: CreateBloodRequestDto) {
    const {
      requesterId,
      hospitalName,
      bloodType,
      unitsNeeded,
      latitude,
      longitude,
      urgency,
    } = dto;

    const request = await this.database.bloodRequest.create({
      data: {
        requesterId,
        hospitalName,
        bloodType,
        unitsNeeded,
        urgency,
        status: 'PENDING',
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
    });

    await this.database.$executeRawUnsafe(`
      UPDATE "blood_requests"
      SET location = ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
      WHERE id = '${request.id}';
    `);

    const nearbyDonors = await this.findCompatibleDonors(
      latitude,
      longitude,
      bloodType,
    );

    return {
      message: 'Kan talebi oluşturuldu ve çevredeki donörler tarandı.',
      requestId: request.id,
      matchResult: {
        foundDonorsCount: nearbyDonors.length,
        donors: nearbyDonors,
      },
      requestDetails: request,
    };
  }

  async findCompatibleDonors(lat: number, lon: number, bloodType: BloodType) {
    const radiusInMeters = 5000; // 5 KM Yarıçap (Değiştirilebilir)

    const donors = await this.database.$queryRaw`
      SELECT 
        u.id as "userId",
        u."phoneNumber",
        dp."firstName",
        dp."lastName",
        dp."bloodType",
        dp."trustScore",
        ST_Distance(
          dp.location, 
          ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326)::geography
        ) as distance_meters
      FROM "donor_profiles" dp
      JOIN "users" u ON dp."userId" = u.id
      WHERE 
        dp."bloodType" = ${bloodType}::"BloodType"
        AND ST_DWithin(
          dp.location,
          ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326)::geography,
          ${radiusInMeters}
        )
      ORDER BY distance_meters ASC;
    `;

    return donors as any[];
  }

  findAll() {
    return this.database.bloodRequest.findMany();
  }
}

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
    const radiusInMeters = 5000;

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

  async findNearbyRequests(lat: number, lon: number, radiusKm: number = 10) {
    const radiusMeters = radiusKm * 1000;

    const requests = await this.database.$queryRaw`
      SELECT
        br.id,
        br."hospitalName",
        br."bloodType",
        br.urgency,
        br.description,
        ST_Distance(
          br.location,
          ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326)::geography
        ) as distance_meters
      FROM "blood_requests" br
      WHERE
        br.status = 'PENDING'
        AND ST_DWithin(
          br.location,
          ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326)::geography,
          ${radiusMeters}
        )
      ORDER BY distance_meters ASC;
        `;

    return requests;
  }

  async acceptRequest(requestId: string, donorId: string) {
    const donorProfile = await this.database.donorProfile.findUnique({
      where: { userId: donorId },
    });

    if (!donorProfile) {
      throw new Error('Donör profili bulunamadı. Lütfen profil oluşturun.');
    }

    const bloodRequest = await this.database.bloodRequest.findUnique({
      where: { id: requestId },
    });

    if (!bloodRequest) throw new Error('Talep bulunamadı.');
    if (bloodRequest.status !== 'PENDING')
      throw new Error('Bu talep artık aktif değil.');

    const nearestCenter: any[] = await this.database.$queryRaw`
      SELECT 
        hp.name,
        hp.address,
        ST_Distance(
          hp.location, 
          (SELECT location FROM "donor_profiles" WHERE "userId" = ${donorId})
        ) as distance_meters
      FROM "hospital_profiles" hp
      WHERE hp."hasBloodBank" = true 
      ORDER BY distance_meters ASC
      LIMIT 1;
    `;

    let targetAddress = 'En Yakın Kızılay Merkezi';
    let instructionMessage = '';

    if (nearestCenter.length > 0) {
      const center = nearestCenter[0];
      const distanceKm = (center.distance_meters / 1000).toFixed(1);

      targetAddress = center.name;
      instructionMessage = `Bağış işlemini tamamlamak için size en yakın nokta olan ${center.name}'ne yönlendirildiniz. (${distanceKm} km)`;
    } else {
      instructionMessage =
        'Sistemde kayıtlı kan bağış merkezi bulunamadı. Lütfen size en yakın Kızılay noktasına gidiniz.';
    }

    const transaction = await this.database.donationTransaction.create({
      data: {
        requestId: requestId,
        donorId: donorId,
        status: 'ACCEPTED',
      },
    });

    await this.database.bloodRequest.update({
      where: { id: requestId },
      data: { status: 'ACTIVE' },
    });

    return {
      message: 'Bağış çağrısı kabul edildi! Yola çıkmaya hazırsınız.',
      instructions: instructionMessage,
      destination: targetAddress,
      details: transaction,
    };
  }

  async reportDonation(requestId: string, donorId: string) {
    const transaction = await this.database.donationTransaction.findUnique({
      where: {
        requestId_donorId: { requestId, donorId },
      },
      include: { request: { include: { requester: true } } },
    });

    if (!transaction) {
      throw new Error('Bağış işlemi bulunamadı.');
    }

    if (transaction.status !== 'ACCEPTED') {
      throw new Error(
        'Henüz kabul edilmemiş ya da zaten tamamlanmış bir işlem.',
      );
    }

    await this.database.donationTransaction.update({
      where: { id: transaction.id },
      data: {
        status: 'ARRIVED',
        arrivedAt: new Date(),
      },
    });

    return {
      message:
        'Bildiriminiz alındı. Lütfen kan bağış barkodunu/belgesini hasta yakınına gönderiniz.',
      nextStep: 'Aşağıdaki numaraya kanıtı iletiniz ve onay bekleyiniz.',
      contactInfo: {
        name: transaction.request.hospitalName,
        phone: transaction.request.requester.phoneNumber,
      },
    };
  }

  async confirmDonation(requestId: string, requesterId: string) {
    const bloodRequest = await this.database.bloodRequest.findUnique({
      where: { id: requestId },
      include: {
        transactions: {
          where: { status: 'ARRIVED' },
        },
      },
    });

    if (!bloodRequest) {
      throw new Error('Kan talebi bulunamadı.');
    }

    if (bloodRequest.requesterId !== requesterId) {
      throw new Error('Bu işlemi gerçekleştirme yetkiniz yok.');
    }

    if (bloodRequest.transactions.length === 0) {
      throw new Error('Onaylanacak bağış işlemi bulunamadı.');
    }

    const transaction = bloodRequest.transactions[0];

    await this.database.$transaction([
      this.database.donationTransaction.update({
        where: { id: transaction.id },
        data: {
          status: 'COMPLETED',
          completedAt: new Date(),
        },
      }),

      this.database.bloodRequest.update({
        where: { id: requestId },
        data: { status: 'FULFILLED' },
      }),

      this.database.donorProfile.update({
        where: { userId: transaction.donorId },
        data: {
          totalDonations: { increment: 1 },
          lastDonationDate: new Date(),
          trustScore: { increment: 1.0 },
        },
      }),
    ]);

    return {
      message: 'Bağış işlemini başarıyla onayladınız. Geçmiş olsun!',
      status: 'COMPLETED',
      donorId: transaction.donorId,
    };
  }

  async getDonorProfile(userId: string) {
    const profile = await this.database.donorProfile.findUnique({
      where: { userId },
      include: {
        user: { select: { phoneNumber: true, role: true } },
      },
    });

    if (!profile) throw new Error('Profil bulunamadı.');

    return {
      message: 'Profil bilgileri getirildi.',
      data: profile,
    };
  }

  findAll() {
    return this.database.bloodRequest.findMany();
  }
}

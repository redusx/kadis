// prisma/seed.ts
import { PrismaClient, BloodType, Gender } from '@prisma/client';

const prisma = new PrismaClient();

// Ankara Hacettepe Koordinatları (Merkez)
const CENTER_LAT = 39.92077;
const CENTER_LON = 32.85411;

async function main() {
  console.log('🌱 Tohumlama Başlıyor (Geography Modu)...');

  // 1. Temizlik: Önceki verileri sil (Sıra önemli: Child -> Parent)
  // deleteMany() tabloları boşaltır.
  await prisma.donationTransaction.deleteMany();
  await prisma.bloodRequest.deleteMany();
  await prisma.donorProfile.deleteMany();
  await prisma.hospitalProfile.deleteMany();
  await prisma.user.deleteMany();

  console.log('🧹 Eski veriler temizlendi.');

  // --- SENARYO 1: YAKINDAKİ KAHRAMANLAR (Hedef Kitle - 5 Kişi) ---
  for (let i = 1; i <= 5; i++) {
    // 0.01 derece yaklaşık 1.1 km eder.
    // Merkezden çok az sapma yapıyoruz (Hastanenin dibindeler)
    const latOffset = Math.random() * 0.02 - 0.01;
    const lonOffset = Math.random() * 0.02 - 0.01;

    const phone = `555100000${i}`;

    // Kullanıcıyı Yarat
    const user = await prisma.user.create({
      data: {
        phoneNumber: phone,
        password: 'hashed_password_123',
        role: 'DONOR',
        isVerified: true,
        kvkkConsent: true, // Yeni KVKK alanı
      },
    });

    // Profili Yarat (Konumsuz)
    await prisma.donorProfile.create({
      data: {
        userId: user.id,
        firstName: `YakinDonör`,
        lastName: `${i}`,
        identityNumber: `1111111111${i}`, // Yeni TCKN alanı
        bloodType: 'A_RH_POS', // Test için hepsi A RH+
        gender: Gender.MALE, // Yeni Gender alanı
        birthDate: new Date('1990-01-01'),
        lastDonationDate: new Date('2023-01-01'), // Bağışa uygun
        trustScore: 10.0, // Yeni Güven Skoru
      },
    });

    // KONUM GÜNCELLEME (Geography Dönüşümlü)
    const lat = CENTER_LAT + latOffset;
    const lon = CENTER_LON + lonOffset;

    // DİKKAT: ::geography eklentisi burada!
    await prisma.$executeRawUnsafe(`
      UPDATE "donor_profiles"
      SET location = ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326)::geography
      WHERE "userId" = '${user.id}';
    `);

    console.log(`✅ Yakın Donör Eklendi: ${phone}`);
  }

  // --- SENARYO 2: UZAKTAKİLER (Eşleşmemesi Gerekenler - 5 Kişi) ---
  for (let i = 1; i <= 5; i++) {
    // 0.2 derece yaklaşık 20 km eder (Gölbaşı tarafı)
    const latOffset = 0.15 + Math.random() * 0.05;

    const phone = `555200000${i}`;

    const user = await prisma.user.create({
      data: {
        phoneNumber: phone,
        password: 'pass',
        role: 'DONOR',
        isVerified: true,
        kvkkConsent: true,
      },
    });

    await prisma.donorProfile.create({
      data: {
        userId: user.id,
        firstName: `UzakDonör`,
        lastName: `${i}`,
        identityNumber: `2222222222${i}`,
        bloodType: 'A_RH_POS',
        gender: Gender.FEMALE,
        birthDate: new Date('1995-05-05'),
        lastDonationDate: new Date('2023-01-01'),
      },
    });

    const lat = CENTER_LAT + latOffset;
    const lon = CENTER_LON;

    await prisma.$executeRawUnsafe(`
      UPDATE "donor_profiles"
      SET location = ST_SetSRID(ST_MakePoint(${lon}, ${lat}), 4326)::geography
      WHERE "userId" = '${user.id}';
    `);

    console.log(`❌ Uzak Donör Eklendi: ${phone}`);
  }

  console.log('🏁 Tohumlama Tamamlandı.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

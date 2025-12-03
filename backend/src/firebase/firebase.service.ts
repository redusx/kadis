import { Injectable, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
  onModuleInit() {
    if (admin.apps.length === 0) {
      admin.initializeApp({
        credential: admin.credential.cert(
          path.join(process.cwd(), 'firebase-service-account.json'),
        ),
      });
      console.log('🔥 Firebase Admin Başlatıldı!');
    }
  }


  async verifyToken(token: string) {
    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      return decodedToken;
    } catch (error) {
      throw new Error('Geçersiz Token veya Doğrulama Hatası');
    }
  }
}
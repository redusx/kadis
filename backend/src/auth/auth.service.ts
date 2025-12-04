import { Injectable } from '@nestjs/common';
import { stat } from 'fs';
import { FirebaseService } from 'src/firebase/firebase.service';

@Injectable()
export class AuthService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async loginWithPhone(token: string) {
    try {
      // Token doğrulama
      const decodedToken = await this.firebaseService.verifyToken(token);

      const phone = decodedToken.phone_number;
      const uid = decodedToken.uid;

      return {
        status: 'success',
        message: 'Kullanıcı Doğrulandı',
        user: {
          uid: uid,
          phone: phone,
        },
      };
    } catch (error) {
      throw new UnauthorizedException(
        'Kimlik doğrulama başarısız! Casus olabilir.',
      );
    }
  }
}

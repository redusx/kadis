import { Module, Global } from '@nestjs/common';
import { FirebaseService } from './firebase.service';

@Global() // Global yapıyoruz ki her yerden (AuthModule vb.) erişebilelim
@Module({
  providers: [FirebaseService],
  exports: [FirebaseService],
})
export class FirebaseModule {}
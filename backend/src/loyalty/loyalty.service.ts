import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LoyaltyAccount, LoyaltyTransaction, RewardQR } from './loyalty.entity';

@Injectable()
export class LoyaltyService {
  constructor(
    @InjectRepository(LoyaltyAccount) private accountRepo: Repository<LoyaltyAccount>,
    @InjectRepository(LoyaltyTransaction) private txRepo: Repository<LoyaltyTransaction>,
    @InjectRepository(RewardQR) private qrRepo: Repository<RewardQR>,
  ) {}

  // Kullanıcının sadakat hesabını getirir (yoksa otomatik oluşturur)
  async getOrCreateAccount(userId: number) {
    let account = await this.accountRepo.findOne({ where: { user_id: userId } });
    if (!account) {
      account = this.accountRepo.create({ user_id: userId, total_points: 0, current_stamps: 0 });
      await this.accountRepo.save(account);
    }
    const history = await this.txRepo.find({
      where: { loyalty_account_id: account.id },
      order: { created_at: 'DESC' },
    });
    return { account, history };
  }

  // Tamamlanan siparişten puan ve damga kazandırır (Çift yazımı engeller)
  async earnFromOrder(userId: number, orderId: number, orderAmount: number) {
    const existing = await this.txRepo.findOne({
      where: { order_id: orderId, transaction_type: 'EARN' },
    });
    if (existing) {
      throw new BadRequestException('Bu sipariş için puan kazanımı zaten işlenmiş.');
    }

    const { account } = await this.getOrCreateAccount(userId);
    const earnedPoints = Math.floor(orderAmount * 0.1); // Tutarın %10'u kadar puan
    const earnedStamps = 1; // Her uygun siparişe 1 damga

    account.total_points += earnedPoints;
    account.current_stamps += earnedStamps;
    await this.accountRepo.save(account);

    const tx = this.txRepo.create({
      loyalty_account_id: account.id,
      order_id: orderId,
      transaction_type: 'EARN',
      points_changed: earnedPoints,
      stamps_changed: earnedStamps,
    });
    await this.txRepo.save(tx);

    return { message: 'Puan ve damga eklendi', account };
  }

  // Sipariş iptalinde geçmiş kaydı silmeden ters hareket (REVERSAL) yazar
  async reverseOrder(userId: number, orderId: number) {
    const earnTx = await this.txRepo.findOne({
      where: { order_id: orderId, transaction_type: 'EARN' },
    });
    if (!earnTx) throw new NotFoundException('İptal edilecek puan kazanımı bulunamadı.');

    const alreadyReversed = await this.txRepo.findOne({
      where: { order_id: orderId, transaction_type: 'REVERSAL' },
    });
    if (alreadyReversed) throw new BadRequestException('Bu siparişin puanı zaten geri alınmış.');

    const { account } = await this.getOrCreateAccount(userId);
    account.total_points = Math.max(0, account.total_points - earnTx.points_changed);
    account.current_stamps = Math.max(0, account.current_stamps - earnTx.stamps_changed);
    await this.accountRepo.save(account);

    const reversalTx = this.txRepo.create({
      loyalty_account_id: account.id,
      order_id: orderId,
      transaction_type: 'REVERSAL',
      points_changed: -earnTx.points_changed,
      stamps_changed: -earnTx.stamps_changed,
    });
    await this.txRepo.save(reversalTx);

    return { message: 'İptal nedeniyle puanlar ters kayıtla geri alındı', account };
  }

  // Müşteri için 15 dakika geçerli tek kullanımlık QR ödül kodu üretir
  async generateRewardQR(userId: number) {
    const token = `QR-${userId}-${Date.now()}`;
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 dakika geçerli

    const qr = this.qrRepo.create({
      user_id: userId,
      reward_type: 'FREE_COFFEE',
      qr_code_token: token,
      is_used: false,
      expires_at: expiresAt,
    });
    return this.qrRepo.save(qr);
  }

  // Şube personelinin QR kodu okutup tüketmesi (İkinci kez kullanılamaz)
  async consumeRewardQR(qrToken: string) {
    const qr = await this.qrRepo.findOne({ where: { qr_code_token: qrToken } });
    if (!qr) throw new NotFoundException('Geçersiz QR kodu.');
    if (qr.is_used) throw new BadRequestException('Bu QR ödül kodu daha önce kullanılmış!');
    if (new Date() > qr.expires_at) throw new BadRequestException('Bu QR kodunun süresi dolmuş.');

    qr.is_used = true;
    await this.qrRepo.save(qr);
    return { message: 'Ödül QR kodu başarıyla doğrulandı ve kullanıldı.', reward: qr.reward_type };
  }
}

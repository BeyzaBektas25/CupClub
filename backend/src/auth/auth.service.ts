import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from './user.entity';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepo: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async register(data: { first_name: string; last_name: string; email: string; password: string }) {
    const existing = await this.userRepo.findOne({ where: { email: data.email } });
    if (existing) {
      throw new BadRequestException('Bu e-posta adresi zaten kayıtlı.');
    }

    const password_hash = await bcrypt.hash(data.password, 10);
    const user = this.userRepo.create({
      first_name: data.first_name,
      last_name: data.last_name,
      email: data.email,
      password_hash,
    });

    await this.userRepo.save(user);
    return { message: 'Kayıt başarılı', userId: user.id };
  }

  async login(data: { email: string; password: string }) {
    const user = await this.userRepo.findOne({ where: { email: data.email } });
    if (!user) {
      throw new UnauthorizedException('E-posta veya şifre hatalı.');
    }

    const isMatch = await bcrypt.compare(data.password, user.password_hash);
    if (!isMatch) {
      throw new UnauthorizedException('E-posta veya şifre hatalı.');
    }

    const payload = { sub: user.id, email: user.email };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
      },
    };
  }
}

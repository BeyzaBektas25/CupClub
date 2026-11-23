import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { InjectDataSource } from '@nestjs/typeorm';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { DataSource } from 'typeorm';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    @InjectDataSource()
    private dataSource: DataSource,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: 'CUPCLUB_SUPER_SECRET_KEY_2026',
    });
  }

  async validate(payload: { sub: number; email: string }) {
    if (!payload.sub || !payload.email) {
      throw new UnauthorizedException('Geçersiz kullanıcı tokenı.');
    }

    const userRoles = await this.dataSource.query(
      `
      SELECT
        r.role_name AS role,
        ur.branch_id AS "branchId"
      FROM "UserRoles" ur
      INNER JOIN "Roles" r ON r.id = ur.role_id
      WHERE ur.user_id = $1
      `,
      [payload.sub],
    );

    if (userRoles.length === 0) {
      throw new UnauthorizedException('Kullanıcıya atanmış bir rol bulunamadı.');
    }

    return {
      id: payload.sub,
      email: payload.email,
      roles: userRoles.map((item: { role: string }) => item.role),
      branchId: userRoles[0].branchId,
    };
  }
}

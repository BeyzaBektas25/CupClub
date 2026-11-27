
import {
  Controller,
  Post,
  Body,
  Get,
  Headers,
  UnauthorizedException,
} from '@nestjs/common';

import {
  ApiTags,
  ApiOperation,
  ApiBody,
  ApiBearerAuth,
} from '@nestjs/swagger';

import { AuthService } from './auth.service';

@ApiTags('Auth (Kayıt ve Giriş)')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Yeni müşteri kaydı oluşturur' })
  @ApiBody({
    schema: {
      type: 'object',
      required: [
        'first_name',
        'last_name',
        'email',
        'password',
        'date_of_birth',
      ],
      properties: {
        first_name: {
          type: 'string',
          example: 'Beyza',
        },
        last_name: {
          type: 'string',
          example: 'Yılmaz',
        },
        email: {
          type: 'string',
          example: 'beyza@cupclub.com',
        },
        password: {
          type: 'string',
          example: '123456',
        },
        date_of_birth: {
          type: 'string',
          format: 'date',
          example: '2000-05-15',
        },
      },
    },
  })
  register(
    @Body()
    body: {
      first_name: string;
      last_name: string;
      email: string;
      password: string;
      date_of_birth: string;
    },
  ) {
    return this.authService.register(body);
  }

  @Post('login')
  @ApiOperation({ summary: 'Kullanıcı girişi yapar ve JWT token döner' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        email: { type: 'string', example: 'beyza@cupclub.com' },
        password: { type: 'string', example: '123456' },
      },
    },
  })
  login(@Body() body: { email: string; password: string }) {
    return this.authService.login(body);
  }

  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Giriş yapan kullanıcının oturumunu doğrular' })
  getProfile(@Headers('authorization') authorization?: string) {
    if (!authorization || !authorization.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token gönderilmedi.');
    }

    const token = authorization.substring(7);

    return this.authService.validateToken(token);
  }
}

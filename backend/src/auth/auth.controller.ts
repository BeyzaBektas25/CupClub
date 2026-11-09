import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody } from '@nestjs/swagger';
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
      properties: {
        first_name: { type: 'string', example: 'Beyza' },
        last_name: { type: 'string', example: 'Yılmaz' },
        email: { type: 'string', example: 'beyza@cupclub.com' },
        password: { type: 'string', example: '123456' },
      },
    },
  })
  register(@Body() body: { first_name: string; last_name: string; email: string; password: string }) {
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
}

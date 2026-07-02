import { Controller, Post, Body, HttpCode } from '@nestjs/common';

@Controller('v1/auth')
export class AuthController {
  @Post('otp/request')
  @HttpCode(200)
  async requestOtp(@Body() body: { phone_number: string }) {
    console.log('OTP request for', body.phone_number);
    // In prod: send SMS via provider and store OTP
    return { sent: true };
  }

  @Post('otp/verify')
  @HttpCode(200)
  async verifyOtp(@Body() body: { phone_number: string; otp: string }) {
    console.log('OTP verify', body.phone_number, body.otp);
    // In prod: validate OTP and issue tokens
    return { access_token: 'dev-token', refresh_token: 'dev-refresh', is_new_user: false };
  }
}

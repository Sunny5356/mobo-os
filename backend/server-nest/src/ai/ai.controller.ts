import { Controller, Post, Param, Req, HttpCode } from '@nestjs/common';

@Controller('v1/ai')
export class AiController {
  @Post('actions/:messageId/confirm')
  @HttpCode(200)
  async confirm(@Req() req: any, @Param('messageId') messageId: string) {
    const tenantId = req.tenantId || 'public-tenant';
    // In a full implementation: lookup AiMessage by id, parse proposedAction, and execute
    console.log('AI confirm for message', messageId, 'tenant', tenantId);
    // Placeholder: return a simple success
    return { status: 'confirmed', messageId };
  }
}

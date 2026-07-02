import { Controller, Post, Body, Param, Req, HttpCode } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Controller('v1/ai')
export class AiConversationsController {
  constructor(private prisma: PrismaService) {}

  @Post('conversations')
  @HttpCode(201)
  async createConversation(@Req() req: any) {
    const tenantId = req.tenantId || 'public-tenant';
    // For now, conversation is represented by a message root id
    const m = await this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      return tx.aiMessage.create({ data: { tenantId, role: 'system', content: 'conversation started' } });
    });
    return { conversation_id: m.id };
  }

  @Post('conversations/:id/messages')
  async postMessage(@Req() req: any, @Param('id') id: string, @Body() body: { content: string }) {
    const tenantId = req.tenantId || 'public-tenant';
    // Save user message and return mock assistant reply with a proposed action
    const userMsg = await this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      return tx.aiMessage.create({ data: { tenantId, role: 'user', content: body.content } });
    });

    const assistant = await this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      return tx.aiMessage.create({
        data: {
          tenantId,
          role: 'assistant',
          content: `I can remind the customer to pay.`,
          proposedAction: JSON.stringify({ type: 'create_reminder', when: new Date().toISOString() }),
        },
      });
    });

    return { id: assistant.id, role: assistant.role, content: assistant.content, proposed_action: assistant.proposedAction };
  }
}

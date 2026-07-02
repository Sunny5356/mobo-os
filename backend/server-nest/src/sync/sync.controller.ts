import { Controller, Post, Body, Req, HttpCode } from '@nestjs/common';
import { SyncService } from './sync.service';

@Controller('v1/sync')
export class SyncController {
  constructor(private sync: SyncService) {}

  @Post('push')
  @HttpCode(200)
  async push(@Req() req: any, @Body() body: { batch: any[] }) {
    const tenantId = req.tenantId || body.tenantId || 'public-tenant';
    const res = await this.sync.applyBatch(tenantId, body.batch || []);
    return { applied: res };
  }
}

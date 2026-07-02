import { Controller, Get, Post, Body, Param, Req } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Controller('v1/customers')
export class CustomersController {
  constructor(private prisma: PrismaService) {}

  @Get()
  async list(@Req() req: any) {
    const tenantId = req.tenantId || 'public-tenant';
    return this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      return tx.customer.findMany();
    });
  }

  @Post()
  async create(@Req() req: any, @Body() body: { name: string; phone?: string }) {
    const tenantId = req.tenantId || 'public-tenant';
    return this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      const c = await tx.customer.create({ data: { tenantId, name: body.name, phone: body.phone } });
      return c;
    });
  }

  @Post(':id/payments')
  async recordPayment(@Req() req: any, @Param('id') id: string, @Body() body: { amount: number }) {
    const tenantId = req.tenantId || 'public-tenant';
    return this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      const entry = await tx.ledgerEntry.create({ data: { tenantId, customerId: id, amount: body.amount, type: 'payment' } });
      // Adjust customer's currentBalance
      await tx.customer.update({ where: { id }, data: { currentBalance: { decrement: body.amount } as any } as any });
      return entry;
    });
  }
}

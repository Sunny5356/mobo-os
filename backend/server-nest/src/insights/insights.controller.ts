import { Controller, Get, Req } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Controller('v1/insights')
export class InsightsController {
  constructor(private prisma: PrismaService) {}

  @Get('summary')
  async summary(@Req() req: any) {
    const tenantId = req.tenantId || 'public-tenant';
    // Simple summary: today's sales total, total receivables, low stock count
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const sales = await this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      const todaySales = await tx.sale.aggregate({
        _sum: { total: true },
        where: { createdAt: { gte: today } },
      });
      const receivables = await tx.ledgerEntry.aggregate({
        _sum: { amount: true },
        where: { type: 'receivable' },
      });
      const lowStockCount = 0; // placeholder: requires item stock field
      return {
        today_sales: todaySales._sum.total || 0,
        total_receivables: receivables._sum.amount || 0,
        low_stock_count: lowStockCount,
      };
    });
    return sales;
  }
}

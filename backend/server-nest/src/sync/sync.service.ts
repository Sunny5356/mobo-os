import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class SyncService {
  constructor(private prisma: PrismaService) {}

  /**
   * Apply a batch of changes for a tenant inside a single transaction.
   * Each change should be an object like: { type: 'customer'|'item'|'sale'|'ledger_entry'|'ai_message', id?, local_id?, payload }
   * Returns an array of results: { local_id, server_id, status, reason? }
   */
  async applyBatch(tenantId: string, batch: any[]) {
    const results: Array<any> = [];

    await this.prisma.runInTenantTransaction(tenantId, async (tx) => {
      for (const change of batch || []) {
        const { type, id, local_id, payload } = change;
        try {
          if (type === 'customer') {
            const up = await tx.customer.upsert({
              where: { id: id || '' },
              create: {
                id: id || undefined,
                tenantId,
                name: payload.name,
                phone: payload.phone,
                email: payload.email,
                currentBalance: payload.currentBalance || 0,
              },
              update: {
                name: payload.name,
                phone: payload.phone,
                email: payload.email,
              },
            });
            results.push({ local_id, server_id: up.id, status: 'applied' });
            continue;
          }

          if (type === 'item') {
            const up = await tx.item.upsert({
              where: { id: id || '' },
              create: {
                id: id || undefined,
                tenantId,
                name: payload.name,
                price: payload.price || 0,
              },
              update: {
                name: payload.name,
                price: payload.price || 0,
              },
            });
            results.push({ local_id, server_id: up.id, status: 'applied' });
            continue;
          }

          if (type === 'sale') {
            // payload: { id?, customerId?, total, items: [{ itemId, qty, price }] }
            const sale = await tx.sale.create({
              data: {
                id: id || undefined,
                tenantId,
                customerId: payload.customerId || null,
                total: payload.total || 0,
                items: {
                  create: (payload.items || []).map((it) => ({ itemId: it.itemId, qty: it.qty || 1, price: it.price || 0 })),
                },
              },
              include: { items: true },
            });
            results.push({ local_id, server_id: sale.id, status: 'applied' });
            continue;
          }

          if (type === 'ledger_entry' || type === 'ledger') {
            const entry = await tx.ledgerEntry.create({
              data: {
                id: id || undefined,
                tenantId,
                customerId: payload.customerId || null,
                amount: payload.amount || 0,
                type: payload.type || 'entry',
              },
            });
            results.push({ local_id, server_id: entry.id, status: 'applied' });
            continue;
          }

          if (type === 'ai_message' || type === 'ai') {
            const m = await tx.aiMessage.create({ data: { id: id || undefined, tenantId, role: payload.role || 'user', content: payload.content || '', proposedAction: payload.proposedAction || null } });
            results.push({ local_id, server_id: m.id, status: 'applied' });
            continue;
          }

          // unknown type -> return as applied but unprocessed
          results.push({ local_id, server_id: null, status: 'ignored', reason: 'unknown_type' });
        } catch (err: any) {
          results.push({ local_id, server_id: null, status: 'error', reason: err?.message || String(err) });
        }
      }
    });

    return results;
  }
}

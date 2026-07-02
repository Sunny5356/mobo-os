import { Module } from '@nestjs/common';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { TenantContextInterceptor } from './common/tenant/tenant-context.interceptor';
import { PrismaService } from './prisma.service';
import { SyncService } from './sync/sync.service';
import { SyncController } from './sync/sync.controller';
import { AiController } from './ai/ai.controller';
import { AiConversationsController } from './ai/conversations.controller';
import { AuthController } from './auth/auth.controller';
import { InsightsController } from './insights/insights.controller';
import { CustomersController } from './customers/customers.controller';

@Module({
  imports: [],
  controllers: [SyncController, AiController, AiConversationsController, AuthController, InsightsController, CustomersController],
  providers: [
    PrismaService,
    SyncService,
    {
      provide: APP_INTERCEPTOR,
      useClass: TenantContextInterceptor,
    },
  ],
})
export class AppModule {}

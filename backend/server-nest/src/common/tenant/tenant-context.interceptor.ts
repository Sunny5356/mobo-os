import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable, from } from 'rxjs';

// NOTE: This stub shows where to set the Postgres session variable `app.current_tenant_id`.
// In a real app using a DB client/connection pool, you'd set the session var within a transaction
// or use a per-request connection that executes: SET LOCAL app.current_tenant_id = '<tenant_uuid>'

@Injectable()
export class TenantContextInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    // Example: extract tenant id from JWT or header. Here we accept a header for demo.
    const tenantId = req.headers['x-tenant-id'];
    if (tenantId) {
      // In a real DB integration, execute SET LOCAL here on the request's DB transaction connection.
      console.log('Tenant context set to', tenantId);
      req.tenantId = tenantId;
    }
    return next.handle();
  }
}

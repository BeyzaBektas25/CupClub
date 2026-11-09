import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';

@Injectable()
export class BranchAccessGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    
    // İstek başlığından (Header) personelin yetkili olduğu şube ID'sini ve rolünü okuyoruz
    const userRole = request.headers['x-user-role'];
    const userBranchId = Number(request.headers['x-branch-id']);
    
    // İstek atılan hedef şube ID'si (URL parametresinden veya gövdeden)
    const targetBranchId = Number(request.params.branchId || request.body.branchId);

    // Merkez yöneticisi (ADMIN) tüm şubelere erişebilir
    if (userRole === 'ADMIN') {
      return true;
    }

    // Şube personeli ise sadece kendi şubesinin verisine erişebilir
    if (userRole === 'BRANCH_STAFF') {
      if (!userBranchId || (targetBranchId && userBranchId !== targetBranchId)) {
        throw new ForbiddenException(
          `Yetkisiz Erişim (403): Şube #${userBranchId} personeli, Şube #${targetBranchId} işlemlerini yönetemez!`,
        );
      }
      return true;
    }

    throw new ForbiddenException('Bu işlem için şube personeli veya yönetici yetkisi gereklidir.');
  }
}

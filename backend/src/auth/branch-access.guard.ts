import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';

@Injectable()
export class BranchAccessGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new UnauthorizedException('Giriş yapmanız gerekiyor.');
    }

    const userRoles: string[] = user.roles || [];
    const userBranchId = user.branchId
      ? Number(user.branchId)
      : null;

    const targetBranchId = Number(
      request.params.branchId || request.body?.branchId,
    );

    // Merkezi yönetici bütün şubelerin işlemlerini yönetebilir.
    if (userRoles.includes('CENTRAL_ADMIN')) {
      return true;
    }

    // Şube personeli yalnızca kendi şubesine erişebilir.
    if (userRoles.includes('BRANCH_STAFF')) {
      if (
        !userBranchId ||
        !targetBranchId ||
        userBranchId !== targetBranchId
      ) {
        throw new ForbiddenException(
          'Yalnızca görevli olduğunuz şubenin işlemlerini yönetebilirsiniz.',
        );
      }

      return true;
    }

    throw new ForbiddenException(
      'Bu işlem için yeterli yetkiniz bulunmuyor.',
    );
  }
}

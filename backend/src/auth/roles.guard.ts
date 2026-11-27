import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';

@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new UnauthorizedException('Giriş yapmanız gerekiyor.');
    }

    const userRoles: string[] = user.roles || [];
    const requiredRoles: string[] =
      Reflect.getMetadata('roles', context.getHandler()) || [];

    if (requiredRoles.length === 0) {
      return true;
    }

    const hasRequiredRole = requiredRoles.some((role) =>
      userRoles.includes(role),
    );

    if (!hasRequiredRole) {
      throw new ForbiddenException(
        'Bu işlem için yeterli yetkiniz bulunmuyor.',
      );
    }

    return true;
  }
}
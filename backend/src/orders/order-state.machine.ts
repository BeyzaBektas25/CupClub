import { BadRequestException } from '@nestjs/common';

export type OrderStatusType =
  | 'Pending'
  | 'Accepted'
  | 'Preparing'
  | 'Ready'
  | 'Delivered'
  | 'Cancelled'
  | 'Rejected';

// State Pattern: Her sipariş durumunun hangi durumlara geçiş yapabileceğini tanımlar
interface OrderStateHandler {
  canTransitionTo(nextStatus: string): boolean;
}

class PendingState implements OrderStateHandler {
  canTransitionTo(nextStatus: string): boolean {
    return ['Accepted', 'Rejected', 'Cancelled'].includes(nextStatus);
  }
}

class AcceptedState implements OrderStateHandler {
  canTransitionTo(nextStatus: string): boolean {
    return ['Preparing', 'Cancelled'].includes(nextStatus);
  }
}

class PreparingState implements OrderStateHandler {
  canTransitionTo(nextStatus: string): boolean {
    return ['Ready'].includes(nextStatus);
  }
}

class ReadyState implements OrderStateHandler {
  canTransitionTo(nextStatus: string): boolean {
    return ['Delivered'].includes(nextStatus);
  }
}

class TerminalState implements OrderStateHandler {
  canTransitionTo(): boolean {
    return false; // Delivered, Cancelled veya Rejected sonrası durum değişemez
  }
}

export class OrderStateMachine {
  private static readonly states: Record<string, OrderStateHandler> = {
    Pending: new PendingState(),
    Accepted: new AcceptedState(),
    Preparing: new PreparingState(),
    Ready: new ReadyState(),
    Delivered: new TerminalState(),
    Cancelled: new TerminalState(),
    Rejected: new TerminalState(),
  };

  static validateTransition(currentStatus: string, nextStatus: string): void {
    const handler = this.states[currentStatus];
    if (!handler || !handler.canTransitionTo(nextStatus)) {
      throw new BadRequestException(
        `Geçersiz durum geçişi: '${currentStatus}' durumundaki sipariş doğrudan '${nextStatus}' durumuna geçirilemez.`,
      );
    }
  }
}

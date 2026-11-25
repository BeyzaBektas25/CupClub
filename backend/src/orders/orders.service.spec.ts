import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { Order } from './order.entity';
import { OrderItem } from './order-item.entity';
import { OrderItemOption } from './order-item-option.entity';
import { BranchProduct } from '../catalog/branch-product.entity';
import { ProductOptionGroup } from '../catalog/product-option-group.entity';
import { BranchOptionPrice } from '../catalog/branch-option-price.entity';
import { OrdersGateway } from './orders.gateway';

describe('OrdersService', () => {
  let service: OrdersService;

  const mockOrderRepo = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    find: jest.fn(),
  };

  const mockBranchProductRepo = {
    findOne: jest.fn(),
  };

  const mockOrdersGateway = {
    notifyOrderStatusChanged: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrdersService,
        { provide: getRepositoryToken(Order), useValue: mockOrderRepo },
        { provide: getRepositoryToken(OrderItem), useValue: {} },
        { provide: getRepositoryToken(OrderItemOption), useValue: {} },
        { provide: getRepositoryToken(BranchProduct), useValue: mockBranchProductRepo },
        { provide: getRepositoryToken(ProductOptionGroup), useValue: { find: jest.fn().mockResolvedValue([]) } },
        { provide: getRepositoryToken(BranchOptionPrice), useValue: { findOne: jest.fn() } },
        { provide: OrdersGateway, useValue: mockOrdersGateway },
      ],
    }).compile();

    service = module.get<OrdersService>(OrdersService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('bos sepet ile siparis verilmeye calisildiginda BadRequestException firlatmali', async () => {
    await expect(
      service.createOrder({ userId: 1, branchId: 1, items: [] }),
    ).rejects.toThrow(BadRequestException);
  });

  it('subede stokta olmayan urun siparis edildiginde BadRequestException firlatmali', async () => {
    mockBranchProductRepo.findOne.mockResolvedValue({
      branch_id: 1,
      product_id: 10,
      price: 95,
      is_in_stock: false,
    });

    await expect(
      service.createOrder({
        userId: 1,
        branchId: 1,
        items: [{ productId: 10, quantity: 1 }],
      }),
    ).rejects.toThrow(BadRequestException);
  });

  it('baska subenin personeli siparis durumunu guncellemeye calistiginda 403 Forbidden firlatmali', async () => {
    mockOrderRepo.findOne.mockResolvedValue({
      id: 100,
      branch_id: 2,
      status: 'Pending',
    });

    await expect(
      service.updateStatus(100, 'Preparing', {
        roles: ['BRANCH_STAFF'],
        branchId: 1,
      }),
    ).rejects.toThrow(ForbiddenException);
  });

  it('yetkili sube personeli durumu guncellediginde siparisi kaydetmeli ve WebSocket bildirimi gondermeli', async () => {
    const order = { id: 100, branch_id: 1, status: 'Pending' };
    mockOrderRepo.findOne.mockResolvedValue(order);
    mockOrderRepo.save.mockResolvedValue({ ...order, status: 'Preparing' });

    const result = await service.updateStatus(100, 'Preparing', {
      roles: ['BRANCH_STAFF'],
      branchId: 1,
    });

    expect(result.status).toBe('Preparing');
    expect(mockOrdersGateway.notifyOrderStatusChanged).toHaveBeenCalledWith(
      100,
      1,
      'Preparing',
    );
  });
});

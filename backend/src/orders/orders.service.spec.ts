
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { BadRequestException } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { Order } from './order.entity';
import { OrderItem } from './order-item.entity';
import { OrderItemOption } from './order-item-option.entity';
import { BranchProduct } from '../catalog/branch-product.entity';
import { ProductOptionGroup } from '../catalog/product-option-group.entity';
import { BranchOptionPrice } from '../catalog/branch-option-price.entity';
import { OrdersGateway } from './orders.gateway';
import { LoyaltyService } from '../loyalty/loyalty.service';

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

  const mockProductOptionGroupRepo = {
    find: jest.fn().mockResolvedValue([]),
  };

  const mockBranchOptionPriceRepo = {
    findOne: jest.fn(),
  };

  const mockOrdersGateway = {
    notifyOrderStatusChanged: jest.fn(),
  };

  const mockLoyaltyService = {
    earnFromOrder: jest.fn(),
    reverseOrder: jest.fn(),
  };

  const mockDataSource = {
    getRepository: jest.fn(() => mockOrderRepo),

    transaction: jest.fn(async (callback) => {
      const manager = {
        getRepository: jest.fn((entity) => {
          if (entity === Order) return mockOrderRepo;
          if (entity === BranchProduct) return mockBranchProductRepo;
          if (entity === ProductOptionGroup) return mockProductOptionGroupRepo;
          if (entity === BranchOptionPrice) return mockBranchOptionPriceRepo;

          if (entity === OrderItem) {
            return { create: jest.fn(), save: jest.fn() };
          }

          if (entity === OrderItemOption) {
            return { create: jest.fn(), save: jest.fn() };
          }

          return {
            create: jest.fn(),
            save: jest.fn(),
            findOne: jest.fn(),
            find: jest.fn(),
          };
        }),
      };

      return callback(manager);
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrdersService,
        { provide: DataSource, useValue: mockDataSource },
        { provide: getRepositoryToken(Order), useValue: mockOrderRepo },
        { provide: getRepositoryToken(OrderItem), useValue: {} },
        { provide: getRepositoryToken(OrderItemOption), useValue: {} },
        {
          provide: getRepositoryToken(BranchProduct),
          useValue: mockBranchProductRepo,
        },
        {
          provide: getRepositoryToken(ProductOptionGroup),
          useValue: mockProductOptionGroupRepo,
        },
        {
          provide: getRepositoryToken(BranchOptionPrice),
          useValue: mockBranchOptionPriceRepo,
        },
        { provide: OrdersGateway, useValue: mockOrdersGateway },
        { provide: LoyaltyService, useValue: mockLoyaltyService },
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

  it('siparis bulunamadiginda hata vermeli', async () => {
    mockOrderRepo.findOne.mockResolvedValue(null);

    await expect(
      service.updateStatus(100, 'Accepted'),
    ).rejects.toThrow();
  });

  it('siparis durumu guncellendiginde siparisi kaydetmeli ve WebSocket bildirimi gondermeli', async () => {
    const order = {
      id: 100,
      branch_id: 1,
      status: 'Pending',
    };

    mockOrderRepo.findOne.mockResolvedValue(order);
    mockOrderRepo.save.mockResolvedValue({
      ...order,
      status: 'Accepted',
    });

    const result = await service.updateStatus(100, 'Accepted');

    expect(result.status).toBe('Accepted');

    expect(mockOrdersGateway.notifyOrderStatusChanged).toHaveBeenCalledWith(
      100,
      1,
      'Accepted',
    );

    expect(mockLoyaltyService.earnFromOrder).not.toHaveBeenCalled();
  });

  it('siparis Completed oldugunda kullaniciya sadakat puani eklemeli', async () => {
    const order = {
      id: 101,
      user_id: 3,
      branch_id: 1,
      final_amount: '168.00',
      status: 'Ready',
    };

    mockOrderRepo.findOne.mockResolvedValue(order);

    mockOrderRepo.save.mockResolvedValue({
      ...order,
      status: 'Completed',
    });

    mockLoyaltyService.earnFromOrder.mockResolvedValue({
      message: 'Puan ve damga eklendi',
    });

    const result = await service.updateStatus(101, 'Completed');

    expect(result.status).toBe('Completed');

    expect(mockLoyaltyService.earnFromOrder).toHaveBeenCalledWith(
      3,
      101,
      168,
    );

    expect(mockOrdersGateway.notifyOrderStatusChanged).toHaveBeenCalledWith(
      101,
      1,
      'Completed',
    );
  });
});

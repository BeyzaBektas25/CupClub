import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BadRequestException } from '@nestjs/common';
import { CampaignsService } from './campaigns.service';
import { Campaign, Coupon } from './campaign.entity';

describe('CampaignsService', () => {
  let service: CampaignsService;

  const mockCampaignRepo = {
    find: jest.fn(),
  };

  const mockCouponRepo = {
    findOne: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CampaignsService,
        { provide: getRepositoryToken(Campaign), useValue: mockCampaignRepo },
        { provide: getRepositoryToken(Coupon), useValue: mockCouponRepo },
      ],
    }).compile();

    service = module.get<CampaignsService>(CampaignsService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('200 TL uzeri sepette %20 indirim kampanyasini dogru hesaplamali', async () => {
    mockCampaignRepo.find.mockResolvedValue([
      {
        id: 1,
        title: 'Hosgeldin %20 Indirimi',
        priority: 10,
        can_combine: false,
        min_cart_amount: 200,
        rules: [{ rule_type: 'DISCOUNT_PERCENT', rule_value: 20 }],
      },
    ]);

    const result = await service.evaluateCart(250);

    expect(result.appliedCampaign).toBe('Hosgeldin %20 Indirimi');
    expect(result.discountAmount).toBe(50);
    expect(result.finalAmount).toBe(200);
  });

  it('kullanim limiti dolmus kupon kodunda BadRequestException firlatmali', async () => {
    mockCampaignRepo.find.mockResolvedValue([]);
    mockCouponRepo.findOne.mockResolvedValue({
      coupon_code: 'DOLUKUPON',
      is_active: true,
      usage_limit: 5,
      used_count: 5,
    });

    await expect(service.evaluateCart(300, 'DOLUKUPON')).rejects.toThrow(BadRequestException);
  });
});

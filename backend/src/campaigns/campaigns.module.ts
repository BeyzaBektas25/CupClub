import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Campaign, CampaignRule, Coupon } from './campaign.entity';
import { CampaignsService } from './campaigns.service';
import { CampaignsController } from './campaigns.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Campaign, CampaignRule, Coupon])],
  controllers: [CampaignsController],
  providers: [CampaignsService],
})
export class CampaignsModule {}

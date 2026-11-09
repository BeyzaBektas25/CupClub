import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { BranchesModule } from './branches/branches.module';
import { CatalogModule } from './catalog/catalog.module';
import { OrdersModule } from './orders/orders.module';
import { CampaignsModule } from './campaigns/campaigns.module';
import { LoyaltyModule } from './loyalty/loyalty.module';
import { ReportsModule } from './reports/reports.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: '127.0.0.1',
      port: 5433,
      username: 'cupclub_admin',
      password: 'cupclub_password123',
      database: 'cupclub_db',
      autoLoadEntities: true,
      synchronize: false,
    }),
    AuthModule,
    BranchesModule,
    CatalogModule,
    OrdersModule,
    CampaignsModule,
    LoyaltyModule,
    ReportsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Category } from './category.entity';
import { Product } from './product.entity';
import { BranchProduct } from './branch-product.entity';
import { CatalogService } from './catalog.service';
import { CatalogController } from './catalog.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Category, Product, BranchProduct])],
  controllers: [CatalogController],
  providers: [CatalogService],
})
export class CatalogModule {}

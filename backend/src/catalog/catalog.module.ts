import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Category } from './category.entity';
import { Product } from './product.entity';
import { BranchProduct } from './branch-product.entity';

import { ProductOptionGroup } from './product-option-group.entity';
import { ProductOption } from './product-option.entity';
import { BranchOptionPrice } from './branch-option-price.entity';

import { CatalogService } from './catalog.service';
import { CatalogController } from './catalog.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Category,
      Product,
      BranchProduct,
      ProductOptionGroup,
      ProductOption,
      BranchOptionPrice,
    ]),
  ],
  controllers: [CatalogController],
  providers: [CatalogService],
})
export class CatalogModule {}
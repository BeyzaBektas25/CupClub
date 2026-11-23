import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
} from '@nestjs/common';

import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { CatalogService } from './catalog.service';

@ApiTags('Catalog (Menü ve Şube Fiyatları)')
@Controller()
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get('categories')
  @ApiOperation({ summary: 'Tüm ürün kategorilerini listeler' })
  getCategories() {
    return this.catalogService.getCategories();
  }

  @Get('branches/:branchId/products')
  @ApiOperation({
    summary: 'Seçilen şubeye özel fiyatları ve stok durumlarıyla ürünleri getirir',
  })
  getBranchProducts(
    @Param('branchId', ParseIntPipe) branchId: number,
  ) {
    return this.catalogService.getBranchMenu(branchId);
  }

  @Get('branches/:branchId/products/:productId/options')
  @ApiOperation({
    summary: 'Ürünün seçenek gruplarını ve ek ücretlerini getirir',
  })
  getProductOptions(
    @Param('branchId', ParseIntPipe) branchId: number,
    @Param('productId', ParseIntPipe) productId: number,
  ) {
    return this.catalogService.getProductOptions(
      branchId,
      productId,
    );
  }
} 
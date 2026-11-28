import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Patch,
  Delete,
  Body,
  UseGuards,
} from '@nestjs/common';
import { UpdateBranchProductDto } from './dto/update-branch-product.dto';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CatalogService } from './catalog.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

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
    summary:
      'Seçilen şubeye özel fiyatları ve stok durumlarıyla ürünleri getirir',
  })
  getBranchProducts(@Param('branchId', ParseIntPipe) branchId: number) {
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
    return this.catalogService.getProductOptions(branchId, productId);
  }
  @Get('products')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Tüm ürünleri listeler' })
  getProducts() {
    return this.catalogService.getProducts();
  }
  @Post('products')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Yeni ürün oluşturur' })
  createProduct(@Body() dto: CreateProductDto) {
    return this.catalogService.createProduct(dto);
  }

  @Patch('products/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Ürün bilgilerini günceller' })
  updateProduct(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateProductDto,
  ) {
    return this.catalogService.updateProduct(id, dto);
  }
  @Delete('products/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Ürünü siler' })
  deleteProduct(@Param('id', ParseIntPipe) id: number) {
    return this.catalogService.deleteProduct(id);
  }
  @Patch('branches/:branchId/products/:productId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Şubeye özel ürün fiyatını ve stok durumunu günceller',
  })
  updateBranchProduct(
    @Param('branchId', ParseIntPipe) branchId: number,
    @Param('productId', ParseIntPipe) productId: number,
    @Body() dto: UpdateBranchProductDto,
  ) {
    return this.catalogService.updateBranchProduct(branchId, productId, dto);
  }
}

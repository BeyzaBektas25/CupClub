import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './product.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Category } from './category.entity';
import { BranchProduct } from './branch-product.entity';
import { ProductOptionGroup } from './product-option-group.entity';
import { BranchOptionPrice } from './branch-option-price.entity';
import { UpdateBranchProductDto } from './dto/update-branch-product.dto';

@Injectable()
export class CatalogService {
  constructor(
    @InjectRepository(Category)
    private categoryRepo: Repository<Category>,

    @InjectRepository(BranchProduct)
    private branchProductRepo: Repository<BranchProduct>,

    @InjectRepository(Product)
    private productRepo: Repository<Product>,

    @InjectRepository(ProductOptionGroup)
    private optionGroupRepo: Repository<ProductOptionGroup>,

    @InjectRepository(BranchOptionPrice)
    private branchOptionPriceRepo: Repository<BranchOptionPrice>,
  ) {}

  getCategories() {
    return this.categoryRepo.find({
      order: { display_order: 'ASC' },
    });
  }
  getProducts() {
    return this.productRepo.find({
      relations: {
        category: true,
      },
      order: {
        id: 'ASC',
      },
    });
  }

  getBranchMenu(branchId: number) {
    return this.branchProductRepo.find({
      where: { branch_id: branchId },
      relations: {
        product: {
          category: true,
        },
      },
    });
  }

  async getProductOptions(branchId: number, productId: number) {
    const groups = await this.optionGroupRepo.find({
      where: { product_id: productId },
      relations: {
        options: true,
      },
    });

    const branchPrices = await this.branchOptionPriceRepo.find({
      where: { branch_id: branchId },
    });

    const branchPriceMap = new Map(
      branchPrices.map((price) => [price.option_id, price.additional_price]),
    );

    return groups.map((group) => ({
      id: group.id,
      name: group.name,
      is_required: group.is_required,
      min_selectable: group.min_selectable,
      max_selectable: group.max_selectable,

      options: group.options.map((option) => ({
        id: option.id,
        name: option.name,
        additional_price: Number(
          branchPriceMap.get(option.id) ?? option.base_additional_price ?? 0,
        ),
      })),
    }));
  }
  async createProduct(dto: CreateProductDto) {
    const category = await this.categoryRepo.findOneBy({
      id: dto.category_id,
    });

    if (!category) {
      throw new NotFoundException('Ürün kategorisi bulunamadı.');
    }

    const product = this.productRepo.create(dto);

    return this.productRepo.save(product);
  }

  async updateProduct(id: number, dto: UpdateProductDto) {
    const product = await this.productRepo.findOneBy({ id });

    if (!product) {
      throw new NotFoundException('Ürün bulunamadı.');
    }

    if (dto.category_id !== undefined) {
      const category = await this.categoryRepo.findOneBy({
        id: dto.category_id,
      });

      if (!category) {
        throw new NotFoundException('Ürün kategorisi bulunamadı.');
      }
    }

    Object.assign(product, dto);

    return this.productRepo.save(product);
  }
  async deleteProduct(id: number) {
    const product = await this.productRepo.findOneBy({ id });

    if (!product) {
      throw new NotFoundException('Ürün bulunamadı.');
    }

    await this.productRepo.remove(product);

    return { message: 'Ürün başarıyla silindi.' };
  }
  async updateBranchProduct(
    branchId: number,
    productId: number,
    dto: UpdateBranchProductDto,
  ) {
    const branchProduct = await this.branchProductRepo.findOneBy({
      branch_id: branchId,
      product_id: productId,
    });

    if (!branchProduct) {
      throw new NotFoundException('Bu ürün seçilen şubede bulunamadı.');
    }

    Object.assign(branchProduct, dto);

    return this.branchProductRepo.save(branchProduct);
  }
}

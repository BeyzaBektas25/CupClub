import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from './category.entity';
import { BranchProduct } from './branch-product.entity';
import { Product } from './product.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class CatalogService {
  constructor(
    @InjectRepository(Category)
    private categoryRepo: Repository<Category>,

    @InjectRepository(BranchProduct)
    private branchProductRepo: Repository<BranchProduct>,

    @InjectRepository(Product)
    private productRepo: Repository<Product>,
  ) {}

  getCategories() {
    return this.categoryRepo.find({ order: { display_order: 'ASC' } });
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
}

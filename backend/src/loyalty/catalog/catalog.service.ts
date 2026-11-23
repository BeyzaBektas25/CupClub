import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from './category.entity';
import { BranchProduct } from './branch-product.entity';

@Injectable()
export class CatalogService {
  constructor(
    @InjectRepository(Category)
    private categoryRepo: Repository<Category>,
    @InjectRepository(BranchProduct)
    private branchProductRepo: Repository<BranchProduct>,
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
}

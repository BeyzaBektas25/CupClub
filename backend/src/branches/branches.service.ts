import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Branch } from './branch.entity';
import { CreateBranchDto } from './dto/create-branch.dto';
import { NotFoundException } from '@nestjs/common';
import { UpdateBranchDto } from './dto/update-branch.dto';

@Injectable()
export class BranchesService {
  async update(id: number, dto: UpdateBranchDto): Promise<Branch> {
    const branch = await this.branchRepository.findOneBy({ id });

    if (!branch) {
      throw new NotFoundException('Şube bulunamadı.');
    }

    Object.assign(branch, dto);

    return this.branchRepository.save(branch);
  }
  constructor(
    @InjectRepository(Branch)
    private branchRepository: Repository<Branch>,
  ) {}

  findAll(): Promise<Branch[]> {
    return this.branchRepository.find({ where: { is_active: true } });
  }

  async create(dto: CreateBranchDto): Promise<Branch> {
    const branch = this.branchRepository.create(dto);

    return this.branchRepository.save(branch);
  }
  async remove(id: number): Promise<void> {
    const branch = await this.branchRepository.findOneBy({ id });

    if (!branch) {
      throw new NotFoundException('Şube bulunamadı.');
    }

    await this.branchRepository.remove(branch);
  }
}

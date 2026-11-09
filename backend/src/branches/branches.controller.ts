import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { BranchesService } from './branches.service';

@ApiTags('Branches (Şubeler)')
@Controller('branches')
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Get()
  @ApiOperation({ summary: 'Aktif olan tüm şubeleri listeler' })
  getAllBranches() {
    return this.branchesService.findAll();
  }
}

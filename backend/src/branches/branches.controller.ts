import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  Delete,
  Param,
  ParseIntPipe,
  Patch,
} from '@nestjs/common';

import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UpdateBranchDto } from './dto/update-branch.dto';
import { BranchesService } from './branches.service';
import { CreateBranchDto } from './dto/create-branch.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@ApiTags('Branches (Şubeler)')
@Controller('branches')
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Get()
  @ApiOperation({ summary: 'Aktif olan tüm şubeleri listeler' })
  getAllBranches() {
    return this.branchesService.findAll();
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Yeni şube oluşturur' })
  createBranch(@Body() dto: CreateBranchDto) {
    return this.branchesService.create(dto);
  }
  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Şube bilgilerini günceller' })
  updateBranch(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateBranchDto,
  ) {
    return this.branchesService.update(id, dto);
  }
  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CENTRAL_ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Şubeyi tamamen siler' })
  removeBranch(@Param('id', ParseIntPipe) id: number) {
    return this.branchesService.remove(id);
  }
}

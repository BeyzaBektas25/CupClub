import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { ReportsService } from './reports.service';

@ApiTags('Reports (Merkez Raporları)')
@Controller('admin/reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('branch-sales')
  @ApiOperation({ summary: 'Şube bazlı sipariş adedi ve toplam ciro özetini döner' })
  getBranchSales() {
    return this.reportsService.getBranchSalesSummary();
  }
}

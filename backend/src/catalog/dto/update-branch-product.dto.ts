import { IsOptional, IsNumber, IsBoolean, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateBranchProductDto {
  @ApiPropertyOptional({ example: 120.50, description: 'Şubeye özel ürün fiyatı' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  price?: number;

  @ApiPropertyOptional({ example: true, description: 'Ürün şubede stokta mı?' })
  @IsOptional()
  @IsBoolean()
  is_in_stock?: boolean;
}
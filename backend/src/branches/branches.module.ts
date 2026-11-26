import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Branch } from './branch.entity';
import { BranchesService } from './branches.service';
import { BranchesController } from './branches.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
  TypeOrmModule.forFeature([Branch]),
  AuthModule,
  ],
  controllers: [BranchesController],
  providers: [BranchesService],
})
export class BranchesModule {}

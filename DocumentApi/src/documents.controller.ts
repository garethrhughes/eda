
import { Body, Controller, Get, Post } from '@nestjs/common';
import { CreateDocumentDto } from './create-document.dto';
import { DocumentsService } from './documents.service';

@Controller('documents')
export class DocumentsController {

  constructor(private readonly documentsService: DocumentsService) {}

  @Get()
  findAll() {
    return this.documentsService.listDocuments();
  }

  @Post()
  create(@Body() createDocumentDto: CreateDocumentDto) {
    return this.documentsService.storeDocument(createDocumentDto);
  }
}

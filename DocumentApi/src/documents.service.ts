import { Injectable } from '@nestjs/common';
import { DocumentDto } from './document.dto';
import { CreateDocumentDto } from './create-document.dto';
import { randomUUID } from 'crypto';
import * as AWS from 'aws-sdk';

@Injectable()
export class DocumentsService {
  async listDocuments(): Promise<DocumentDto[]> {
    const client = new AWS.DynamoDB.DocumentClient({ apiVersion: "2012-08-10" });
    const result = await client.scan({
      TableName: 'eda-api-table',
      Limit: 50
    }).promise();

    return result.Items.sort((a, b) => a.timestamp > b.timestamp ? -1 : 1) as DocumentDto[];
  }

  async storeDocument(createDocumentDto: CreateDocumentDto): Promise<DocumentDto> {
    const document = new DocumentDto();
    document.id = randomUUID();
    document.timestamp = Date.now();
    document.name = createDocumentDto.name;
    document.path = createDocumentDto.path;

    const client = new AWS.DynamoDB.DocumentClient({ apiVersion: "2012-08-10" });
    await client.put({
      TableName: 'eda-api-table',
      Item: document
    }).promise();

    return document;
  }
}

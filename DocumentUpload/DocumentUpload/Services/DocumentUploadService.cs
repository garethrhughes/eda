using Amazon.S3;
using Amazon.S3.Model;

namespace DocumentUpload.Services;

public interface IDocumentUploadService
{
    Task Upload(IFormFile file, string path);
}

public class DocumentUploadService : IDocumentUploadService
{
    public async Task Upload(IFormFile file, string path)
    {
        var s3Client = new AmazonS3Client();
        var putRequest = new PutObjectRequest
        {
            BucketName = "eda-storage-bucket",
            Key = path,
            InputStream = file.OpenReadStream()
        };
    
        await s3Client.PutObjectAsync(putRequest);
    }
}
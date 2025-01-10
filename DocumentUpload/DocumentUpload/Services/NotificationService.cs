using System.Text.Json;
using Amazon.SimpleNotificationService;
using Amazon.SimpleNotificationService.Model;

namespace DocumentUpload.Services;

public interface INotificationService
{
    Task Send(string fileName, string path);
}

public class NotificationService : INotificationService
{
    public async Task Send(string fileName, string path)
    {
        var snsClient = new AmazonSimpleNotificationServiceClient();
        await snsClient.PublishAsync(new PublishRequest
        {
            TopicArn = "arn:aws:sns:ap-southeast-2:905418130127:my-sns-topic",
            Message =  JsonSerializer.Serialize(new
            {
                MessageType = "DocumentUploaded",
                DocumentPath = path,
                FileName = fileName,
                TimeStamp = DateTime.UtcNow
            })
        });
    }
}
using System.Diagnostics;
using System.Text.Json;
using Amazon.S3;
using Amazon.S3.Model;
using Amazon.SimpleNotificationService;
using Amazon.SimpleNotificationService.Model;
using Microsoft.AspNetCore.Mvc;
using DocumentUpload.Models;
using DocumentUpload.Services;

namespace DocumentUpload.Controllers;

public class HomeController(
    ILogger<HomeController> logger,
    INotificationService notificationService,
    IDocumentUploadService documentUploadService)
    : Controller
{
    private readonly ILogger<HomeController> _logger = logger;

    public IActionResult Index()
    {
        return View();
    }
    
    [HttpPost]
    public async Task<IActionResult> Upload()
    {
        var file = Request.Form.Files[0];
        var path = $"{DateTime.UtcNow.Ticks}/{file.FileName.ToLowerInvariant()}";

        await documentUploadService.Upload(file, path);
        await notificationService.Send(file.FileName, path);
        
        return RedirectToAction("Index");
    }
    

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
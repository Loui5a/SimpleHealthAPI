
namespace CodingTestEverllence
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            var appStartupTime = DateTime.UtcNow;

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Services.AddHealthChecks()
                .AddCheck("startup_delay", () =>
                {
                    var uptime = DateTime.UtcNow -appStartupTime;
                    if ( uptime < TimeSpan.FromSeconds(30))
                    {
                        return Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Unhealthy("Application is still starting up");
                    }
                    return Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy("Application is ready");
                });
            
            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }
            app.Use(async (context, next) =>
            {
                if (context.Request.Path == "/health")
                {
                    var logger = context.RequestServices.GetRequiredService<ILogger<Program>>(); 
                    logger.LogInformation("Health endpoint was called: {Path}", context.Request.Path);
                }
                await next();
            });

            app.MapHealthChecks("/health");

            app.UseHttpsRedirection();

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}

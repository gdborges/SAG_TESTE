using SagPoc.Web.Middleware;
using SagPoc.Web.Services;
using SagPoc.Web.Services.Database;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Register SagContext for session context (usuario, empresa, modulo)
builder.Services.AddSagContext();

// Register DbProvider (SQL Server ou Oracle baseado em appsettings.json)
builder.Services.AddDbProvider(builder.Configuration);

// Register MetadataService
builder.Services.AddScoped<IMetadataService, MetadataService>();

// Register LookupService for T/IT field combos
builder.Services.AddScoped<ILookupService, LookupService>();

// Register ConsultaService for grid queries and CRUD
builder.Services.AddScoped<IConsultaService, ConsultaService>();

// Register EventService for PLSAG events
builder.Services.AddScoped<IEventService, EventService>();

// Register MovementService for movement table CRUD operations
builder.Services.AddScoped<IMovementService, MovementService>();

// Register SequenceService for automatic sequence number generation
builder.Services.AddScoped<ISequenceService, SequenceService>();

// Register ValidationService for protected field modification validation
builder.Services.AddScoped<IValidationService, ValidationService>();

// Register ModuleService for SAG modules and windows API
builder.Services.AddScoped<IModuleService, ModuleService>();

// Register DashboardService for dashboard API (Vision integration)
builder.Services.AddScoped<IDashboardService, DashboardService>();

// Configure CORS for Vision Web integration
builder.Services.AddCors(options =>
{
    options.AddPolicy("VisionWeb", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",    // Vision Web dev server
                "http://localhost:3001",    // Vision Web alternate port
                "http://localhost:5173",    // Vite default port
                "http://localhost:8080",    // Alternate dev port
                "http://127.0.0.1:3000",
                "http://127.0.0.1:5173",
                "http://vision.local"       // Production
            )
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

var app = builder.Build();

// Log do provider selecionado (usa scope para resolver serviços Scoped)
using (var scope = app.Services.CreateScope())
{
    var dbProvider = scope.ServiceProvider.GetRequiredService<IDbProvider>();
    app.Logger.LogInformation("Banco de dados configurado: {Provider}", dbProvider.ProviderName);
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

// Enable CORS for Vision Web integration
app.UseCors("VisionWeb");

// Enable SagContext middleware (captures usuario, empresa, modulo from request)
app.UseSagContext();

app.UseAuthorization();

app.UseStaticFiles();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");


app.Run();

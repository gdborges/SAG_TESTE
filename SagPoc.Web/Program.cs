using SagPoc.Web.Services;
using SagPoc.Web.Services.Database;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

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

var app = builder.Build();

// Log do provider selecionado
var dbProvider = app.Services.GetRequiredService<IDbProvider>();
app.Logger.LogInformation("Banco de dados configurado: {Provider}", dbProvider.ProviderName);

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();

app.UseStaticFiles();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");


app.Run();

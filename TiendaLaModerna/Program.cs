using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi.Models;
using Sysinfocus.AspNetCore.Components;
using System.Reflection;
using TiendaLaModerna.Components;
using TiendaLaModerna.Components.Models.Catalogo;
using TiendaLaModerna.Components.Repository;
using TiendaLaModerna.Data;
using TiendaLaModerna.Services;
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContextFactory<TiendaLaModernaContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("TiendaLaModernaContext") ?? throw new InvalidOperationException("Connection string 'TiendaLaModernaContext' not found.")));

builder.Services.AddQuickGridEntityFrameworkAdapter();

builder.Services.AddDatabaseDeveloperPageExceptionFilter();

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddControllers()
    .AddApplicationPart(Assembly.GetExecutingAssembly()) 
    .AddControllersAsServices();

builder.Services.AddCors(builder =>
{
    builder.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader();
    });
});

builder.Services.AddSysinfocus(false);
builder.Services.AddScoped<IFlowbiteService, FlowbiteService>();
builder.Services.AddScoped<CategoriaRepositorio>();

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Configurar JSON para mejor formato
        options.JsonSerializerOptions.WriteIndented = true;
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Tienda La Moderna API",
        Version = "v1",
        Description = "API para gestión de catálogos de Tienda La Moderna"
    });

    c.SupportNonNullableReferenceTypes();

    c.UseAllOfForInheritance();
    c.UseOneOfForPolymorphism();
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
    app.UseMigrationsEndPoint();

}
else
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Tienda La Moderna API V1");
        c.RoutePrefix = "swagger"; // Esto hace que Swagger esté en /swagger
    });
   
    app.UseDeveloperExceptionPage();
}

    app.UseHttpsRedirection();

app.UseCors(x => x.AllowAnyMethod().AllowAnyHeader().SetIsOriginAllowed(origin=>true).AllowCredentials());
app.UseAntiforgery();

app.MapControllers();
app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();

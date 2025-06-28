using Microsoft.AspNetCore.Components;
using TiendaLaModerna.Services;

namespace TiendaLaModerna.Pages;

public abstract class FlowbitePage : ComponentBase
{
    [Inject]
    protected IFlowbiteService FlowbiteService { get; set; } = default!;

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await FlowbiteService.InitializeFlowbiteAsync();
        }
        await base.OnAfterRenderAsync(firstRender);
    }
}
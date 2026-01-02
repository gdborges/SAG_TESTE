using Microsoft.AspNetCore.Mvc;
using SagPoc.Web.Models;
using SagPoc.Web.Services;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller para operações de movimento (registros filhos de um cabeçalho).
/// </summary>
[Route("api/movement")]
[ApiController]
public class MovementController : ControllerBase
{
    private readonly IMovementService _movementService;
    private readonly IMetadataService _metadataService;
    private readonly IEventService _eventService;
    private readonly ILogger<MovementController> _logger;

    public MovementController(
        IMovementService movementService,
        IMetadataService metadataService,
        IEventService eventService,
        ILogger<MovementController> logger)
    {
        _movementService = movementService;
        _metadataService = metadataService;
        _eventService = eventService;
        _logger = logger;
    }

    /// <summary>
    /// Lista as tabelas de movimento de um cabeçalho.
    /// GET /api/movement/{parentTableId}/tables
    /// </summary>
    [HttpGet("{parentTableId}/tables")]
    public async Task<IActionResult> GetMovementTables(int parentTableId)
    {
        try
        {
            var movements = await _metadataService.GetMovementTablesAsync(parentTableId);
            return Ok(movements.Select(m => new
            {
                m.CodiTabe,
                m.NomeTabe,
                m.GravTabe,
                m.SeriTabe,
                m.IsInline,
                TabName = m.GetCleanTabName(),
                HasChildren = m.HasChildren,
                ChildrenCount = m.Children.Count
            }));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao listar movimentos do cabeçalho {ParentTableId}", parentTableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém dados do grid de movimento.
    /// GET /api/movement/{parentId}/{tableId}/data?page=1&pageSize=50
    /// </summary>
    [HttpGet("{parentId}/{tableId}/data")]
    public async Task<IActionResult> GetMovementData(int parentId, int tableId, int page = 1, int pageSize = 50)
    {
        try
        {
            var data = await _movementService.GetMovementDataAsync(parentId, tableId, page, pageSize);
            return Ok(data);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter dados do movimento {TableId} para pai {ParentId}", tableId, parentId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém os campos do formulário de movimento para o modal.
    /// GET /api/movement/{tableId}/form
    /// </summary>
    [HttpGet("{tableId}/form")]
    public async Task<IActionResult> GetMovementForm(int tableId)
    {
        try
        {
            var fields = await _metadataService.GetMovementFieldsAsync(tableId);
            var metadata = await _movementService.GetMovementMetadataAsync(tableId);

            return Ok(new
            {
                TableId = tableId,
                TableName = metadata?.GravTabe ?? string.Empty,
                PkColumnName = metadata?.PkColumnName ?? "ID",
                Fields = fields.Where(f => !f.IsHidden).Select(f => new
                {
                    f.NomeCamp,
                    f.LabeCamp,
                    f.CompCamp,
                    f.TamaCamp,
                    f.AltuCamp,
                    f.ObriCamp,
                    f.DesaCamp,
                    f.MascCamp,
                    f.GuiaCamp,
                    f.OrdeCamp
                })
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter formulário do movimento {TableId}", tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém um registro de movimento para edição.
    /// GET /api/movement/{tableId}/record/{recordId}
    /// </summary>
    [HttpGet("{tableId}/record/{recordId}")]
    public async Task<IActionResult> GetMovementRecord(int tableId, int recordId)
    {
        try
        {
            var record = await _movementService.GetMovementRecordAsync(tableId, recordId);
            if (record == null)
            {
                return NotFound(new { error = "Registro não encontrado" });
            }
            return Ok(record);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter registro {RecordId} do movimento {TableId}", recordId, tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Insere um novo registro de movimento.
    /// POST /api/movement/{tableId}
    /// Body: { parentId: int, fields: { ... } }
    /// </summary>
    [HttpPost("{tableId}")]
    public async Task<IActionResult> InsertMovement(int tableId, [FromBody] MovementInsertRequest request)
    {
        try
        {
            // Valida se a tabela de movimento pertence ao cabeçalho
            var metadata = await _movementService.GetMovementMetadataAsync(tableId);
            if (metadata == null)
            {
                return BadRequest(new { success = false, message = "Tabela de movimento não encontrada" });
            }

            var result = await _movementService.InsertMovementAsync(tableId, request.ParentId, request.Fields);

            if (result.Success)
            {
                return Ok(result);
            }
            else
            {
                return BadRequest(result);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao inserir no movimento {TableId}", tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Atualiza um registro de movimento.
    /// PUT /api/movement/{tableId}/{recordId}
    /// Body: { fields: { ... } }
    /// </summary>
    [HttpPut("{tableId}/{recordId}")]
    public async Task<IActionResult> UpdateMovement(int tableId, int recordId, [FromBody] MovementUpdateRequest request)
    {
        try
        {
            var result = await _movementService.UpdateMovementAsync(tableId, recordId, request.Fields);

            if (result.Success)
            {
                return Ok(result);
            }
            else
            {
                return BadRequest(result);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao atualizar registro {RecordId} do movimento {TableId}", recordId, tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Exclui um registro de movimento.
    /// DELETE /api/movement/{tableId}/{recordId}
    /// </summary>
    [HttpDelete("{tableId}/{recordId}")]
    public async Task<IActionResult> DeleteMovement(int tableId, int recordId)
    {
        try
        {
            var result = await _movementService.DeleteMovementAsync(tableId, recordId);

            if (result.Success)
            {
                return Ok(result);
            }
            else
            {
                return BadRequest(result);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao excluir registro {RecordId} do movimento {TableId}", recordId, tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Obtém eventos PLSAG de uma tabela de movimento.
    /// GET /api/movement/{parentTableId}/{tableId}/events
    /// </summary>
    [HttpGet("{parentTableId}/{tableId}/events")]
    public async Task<IActionResult> GetMovementEvents(int parentTableId, int tableId)
    {
        try
        {
            var events = await _eventService.GetMovementEventsAsync(parentTableId, tableId);
            return Ok(events);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter eventos do movimento {TableId} (pai {ParentTableId})", tableId, parentTableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém eventos de campo de uma tabela de movimento.
    /// GET /api/movement/{tableId}/field-events
    /// </summary>
    [HttpGet("{tableId}/field-events")]
    public async Task<IActionResult> GetMovementFieldEvents(int tableId)
    {
        try
        {
            var events = await _eventService.GetFieldEventsAsync(tableId);
            return Ok(events);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter eventos de campo do movimento {TableId}", tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém metadados de uma tabela de movimento.
    /// GET /api/movement/{tableId}/metadata
    /// </summary>
    [HttpGet("{tableId}/metadata")]
    public async Task<IActionResult> GetMovementMetadata(int tableId)
    {
        try
        {
            var metadata = await _movementService.GetMovementMetadataAsync(tableId);
            if (metadata == null)
            {
                return NotFound(new { error = "Movimento não encontrado" });
            }

            return Ok(new
            {
                metadata.CodiTabe,
                metadata.NomeTabe,
                metadata.GravTabe,
                metadata.SiglTabe,
                metadata.CabeTabe,
                metadata.SeriTabe,
                metadata.IsInline,
                TabName = metadata.GetCleanTabName(),
                metadata.PkColumnName,
                Columns = metadata.GetGridColumns()
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter metadados do movimento {TableId}", tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }
}

/// <summary>
/// Request para inserir um registro de movimento.
/// </summary>
public class MovementInsertRequest
{
    /// <summary>
    /// ID do registro pai (cabeçalho)
    /// </summary>
    public int ParentId { get; set; }

    /// <summary>
    /// Campos e valores do registro
    /// </summary>
    public Dictionary<string, object?> Fields { get; set; } = new();
}

/// <summary>
/// Request para atualizar um registro de movimento.
/// </summary>
public class MovementUpdateRequest
{
    /// <summary>
    /// Campos e valores atualizados
    /// </summary>
    public Dictionary<string, object?> Fields { get; set; } = new();
}

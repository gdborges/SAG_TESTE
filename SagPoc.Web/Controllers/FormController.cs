using Microsoft.AspNetCore.Mvc;
using SagPoc.Web.Models;
using SagPoc.Web.Services;

namespace SagPoc.Web.Controllers;

/// <summary>
/// Controller para renderização dinâmica de formulários.
/// </summary>
public class FormController : Controller
{
    private readonly IMetadataService _metadataService;
    private readonly ILookupService _lookupService;
    private readonly IConsultaService _consultaService;
    private readonly IEventService _eventService;
    private readonly IValidationService _validationService;
    private readonly ILogger<FormController> _logger;

    public FormController(
        IMetadataService metadataService,
        ILookupService lookupService,
        IConsultaService consultaService,
        IEventService eventService,
        IValidationService validationService,
        ILogger<FormController> logger)
    {
        _metadataService = metadataService;
        _lookupService = lookupService;
        _consultaService = consultaService;
        _eventService = eventService;
        _validationService = validationService;
        _logger = logger;
    }

    /// <summary>
    /// Lista os formulários disponíveis.
    /// </summary>
    public async Task<IActionResult> Index()
    {
        try
        {
            var tables = await _metadataService.GetAvailableTablesAsync();
            return View(tables);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao listar formulários");
            return View("Error", new ErrorViewModel { RequestId = HttpContext.TraceIdentifier });
        }
    }

    /// <summary>
    /// Renderiza um formulário dinamicamente baseado nos metadados.
    /// </summary>
    /// <param name="id">ID da tabela (CodiTabe)</param>
    public async Task<IActionResult> Render(int id)
    {
        try
        {
            _logger.LogInformation("Renderizando formulário {TableId}", id);

            var formMetadata = await _metadataService.GetFormMetadataAsync(id);

            if (formMetadata.Fields.Count == 0)
            {
                _logger.LogWarning("Nenhum campo encontrado para tabela {TableId}", id);
                return NotFound($"Nenhum campo encontrado para a tabela {id}");
            }

            // Popular LookupOptions para campos T/IT com SQL_CAMP
            await PopulateLookupOptionsAsync(formMetadata.Fields);

            // Carrega metadados da tabela e consultas
            var tableMetadata = await _consultaService.GetTableMetadataAsync(id);
            var consultas = await _consultaService.GetConsultasByTableAsync(id);

            // Carrega eventos PLSAG
            var formEvents = await _eventService.GetFormEventsAsync(id);
            var fieldEvents = await _eventService.GetFieldEventsAsync(id);

            _logger.LogInformation("Eventos carregados: Form={HasFormEvents}, Fields={FieldCount}",
                formEvents.HasEvents, fieldEvents.Count);

            // Monta o ViewModel
            var viewModel = new FormRenderViewModel
            {
                Form = formMetadata,
                Table = tableMetadata,
                Consultas = consultas,
                FormEvents = formEvents,
                FieldEvents = fieldEvents
            };

            return View(viewModel);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao renderizar formulário {TableId}", id);
            return View("Error", new ErrorViewModel { RequestId = HttpContext.TraceIdentifier });
        }
    }

    /// <summary>
    /// Renderiza um formulário para embedding (sem layout master).
    /// Usado pelo Vision Web para carregar forms SAG dentro de iframe.
    /// </summary>
    /// <param name="id">ID da tabela (CodiTabe)</param>
    [HttpGet("Form/RenderEmbedded/{id}")]
    public async Task<IActionResult> RenderEmbedded(int id)
    {
        try
        {
            _logger.LogInformation("Renderizando formulário embedded {TableId}", id);

            var formMetadata = await _metadataService.GetFormMetadataAsync(id);

            if (formMetadata.Fields.Count == 0)
            {
                _logger.LogWarning("Nenhum campo encontrado para tabela {TableId}", id);
                return NotFound($"Nenhum campo encontrado para a tabela {id}");
            }

            // Popular LookupOptions para campos T/IT com SQL_CAMP
            await PopulateLookupOptionsAsync(formMetadata.Fields);

            // Carrega metadados da tabela e consultas
            var tableMetadata = await _consultaService.GetTableMetadataAsync(id);
            var consultas = await _consultaService.GetConsultasByTableAsync(id);

            // Carrega eventos PLSAG
            var formEvents = await _eventService.GetFormEventsAsync(id);
            var fieldEvents = await _eventService.GetFieldEventsAsync(id);

            _logger.LogInformation("Eventos carregados (embedded): Form={HasFormEvents}, Fields={FieldCount}",
                formEvents.HasEvents, fieldEvents.Count);

            // Monta o ViewModel
            var viewModel = new FormRenderViewModel
            {
                Form = formMetadata,
                Table = tableMetadata,
                Consultas = consultas,
                FormEvents = formEvents,
                FieldEvents = fieldEvents
            };

            // View sem layout master
            return View("RenderEmbedded", viewModel);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao renderizar formulário embedded {TableId}", id);
            return Content($"<html><body><h3>Erro ao carregar formulário</h3><p>{ex.Message}</p></body></html>", "text/html");
        }
    }

    /// <summary>
    /// Popula as opções de lookup para campos L/T/IT/IL que têm SQL_CAMP definido.
    /// </summary>
    private async Task PopulateLookupOptionsAsync(List<FieldMetadata> fields)
    {
        var lookupTypes = new[] { "L", "T", "IT", "IL" };
        var lookupFields = fields.Where(f =>
            lookupTypes.Contains(f.CompCamp?.ToUpper()) &&
            !string.IsNullOrEmpty(f.SqlCamp));

        foreach (var field in lookupFields)
        {
            try
            {
                field.LookupOptions = await _lookupService.ExecuteLookupQueryAsync(field.SqlCamp!);
                _logger.LogDebug("Campo {FieldName}: {Count} opções carregadas",
                    field.NomeCamp, field.LookupOptions?.Count ?? 0);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Erro ao carregar lookup para campo {FieldName}", field.NomeCamp);
                field.LookupOptions = new List<LookupItem>();
            }
        }
    }

    /// <summary>
    /// Retorna os campos de um formulário em JSON (para debug/API).
    /// </summary>
    /// <param name="id">ID da tabela</param>
    [HttpGet]
    public async Task<IActionResult> Fields(int id)
    {
        try
        {
            var fields = await _metadataService.GetFieldsByTableAsync(id);
            return Json(fields);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter campos da tabela {TableId}", id);
            return StatusCode(500, ex.Message);
        }
    }

    #region API Endpoints para Consulta/CRUD

    /// <summary>
    /// Retorna as consultas disponíveis para uma tabela.
    /// Prioriza SISTCONS, com fallback para GRIDTABE de SISTTABE.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetConsultas(int tableId)
    {
        try
        {
            var response = await _consultaService.GetConsultasWithFallbackAsync(tableId);
            return Json(new
            {
                consultas = response.Consultas.Select(c => new
                {
                    c.CodiCons,
                    c.NomeCons,
                    c.BuscCons,
                    c.SqlCons,
                    c.WherCons,
                    c.OrByCons,
                    Columns = c.GetColumns()
                }),
                source = response.Source
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter consultas da tabela {TableId}", tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Executa uma consulta com filtros e paginação.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> ExecuteConsulta([FromBody] GridFilterRequest request)
    {
        try
        {
            var result = await _consultaService.ExecuteConsultaAsync(request);
            return Json(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar consulta {ConsultaId}", request.ConsultaId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém um registro pelo ID.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetRecord(int tableId, int recordId)
    {
        try
        {
            var record = await _consultaService.GetRecordByIdAsync(tableId, recordId);
            if (record == null)
                return NotFound(new { error = "Registro não encontrado" });

            return Json(record);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter registro {RecordId} da tabela {TableId}", recordId, tableId);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Salva (insere ou atualiza) um registro.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> SaveRecord([FromBody] SaveRecordRequest request)
    {
        try
        {
            var result = await _consultaService.SaveRecordAsync(request);
            if (result.Success)
                return Json(result);
            else
                return BadRequest(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao salvar registro na tabela {TableId}", request.TableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Exclui um registro.
    /// </summary>
    [HttpDelete]
    public async Task<IActionResult> DeleteRecord(int tableId, int recordId)
    {
        try
        {
            var result = await _consultaService.DeleteRecordAsync(tableId, recordId);
            if (result.Success)
                return Json(result);
            else
                return BadRequest(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao excluir registro {RecordId} da tabela {TableId}", recordId, tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Cria um registro vazio para iniciar modo de inclusão (Saga Pattern).
    /// O registro é criado imediatamente no banco. Se o usuário cancelar,
    /// deve chamar CancelRecord para excluí-lo.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> CreateRecord(int tableId)
    {
        try
        {
            _logger.LogInformation("Criando registro vazio para tabela {TableId} (Saga Pattern)", tableId);
            var recordId = await _consultaService.CreateEmptyRecordAsync(tableId);
            return Json(new { success = true, recordId });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao criar registro vazio na tabela {TableId}", tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Obtém os valores default para campos de uma tabela.
    /// Usado para popular o formulário quando o usuário clica em "Novo".
    /// GET /Form/GetFieldDefaults?tableId={id}
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetFieldDefaults(int tableId)
    {
        try
        {
            var defaults = await _consultaService.GetFieldDefaultsAsync(tableId);
            return Json(new { success = true, defaults });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter defaults da tabela {TableId}", tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Cancela uma inclusão excluindo o registro e seus movimentos (Saga Pattern).
    /// Usado quando o usuário inicia um novo registro mas desiste de salvar.
    /// </summary>
    [HttpDelete]
    [Route("Form/CancelRecord/{tableId}/{recordId}")]
    public async Task<IActionResult> CancelRecord(int tableId, int recordId)
    {
        try
        {
            _logger.LogInformation("Cancelando inclusão: excluindo registro {RecordId} e movimentos da tabela {TableId}",
                recordId, tableId);
            var result = await _consultaService.DeleteRecordWithMovementsAsync(tableId, recordId);
            if (result.Success)
                return Json(result);
            else
                return BadRequest(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao cancelar registro {RecordId} da tabela {TableId}", recordId, tableId);
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }

    /// <summary>
    /// Executa uma query de lookup e retorna os resultados completos.
    /// POST /Form/ExecuteLookup
    /// Body: { "sql": "SELECT ...", "filter": "termo de busca" }
    ///
    /// Retorna:
    /// - columns: Lista de nomes das colunas (uppercase)
    /// - records: Lista de registros com key, value e data (todos os campos)
    ///
    /// Similar ao TDBLookNume do Delphi que mantém todos os dados do registro
    /// para preencher campos IE associados.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> ExecuteLookup([FromBody] LookupQueryRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.Sql))
                return BadRequest(new { error = "SQL não informado" });

            var result = await _lookupService.ExecuteLookupQueryFullAsync(request.Sql);

            // Aplica filtro se informado
            if (!string.IsNullOrWhiteSpace(request.Filter))
            {
                var filter = request.Filter.ToLower();
                result.Records = result.Records.Where(r =>
                    r.Key.ToLower().Contains(filter) ||
                    r.Value.ToLower().Contains(filter) ||
                    r.Data.Values.Any(v => v.ToLower().Contains(filter))
                ).ToList();
            }

            return Json(new
            {
                success = true,
                columns = result.Columns,
                records = result.Records.Select(r => new
                {
                    key = r.Key,
                    value = r.Value,
                    data = r.Data
                })
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar lookup");
            return StatusCode(500, new { success = false, error = ex.Message });
        }
    }

    /// <summary>
    /// Obtém o SQL de lookup de um campo pelo CodiCamp.
    /// GET /Form/GetFieldLookupSql?codiCamp={codiCamp}
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetFieldLookupSql(int codiCamp)
    {
        try
        {
            var sql = await _metadataService.GetFieldLookupSqlAsync(codiCamp);
            if (string.IsNullOrEmpty(sql))
                return NotFound(new { error = "Campo não tem SQL de lookup" });

            return Json(new { success = true, sql });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter SQL de lookup do campo {CodiCamp}", codiCamp);
            return StatusCode(500, new { success = false, error = ex.Message });
        }
    }

    /// <summary>
    /// Busca um registro de lookup específico pelo código digitado.
    /// POST /Form/LookupByCode
    /// Body: { "sql": "SELECT ...", "code": "123" }
    ///
    /// Usado quando o usuário digita diretamente o código no campo lookup.
    /// Comportamento similar ao TDBLookNume do Delphi no evento OnExit.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> LookupByCode([FromBody] LookupByCodeRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.Sql))
                return BadRequest(new { success = false, error = "SQL não informado" });

            if (string.IsNullOrWhiteSpace(request.Code))
                return BadRequest(new { success = false, error = "Código não informado" });

            var record = await _lookupService.LookupByCodeAsync(request.Sql, request.Code);

            if (record == null)
            {
                return Json(new
                {
                    success = true,
                    found = false,
                    message = "Código não encontrado"
                });
            }

            return Json(new
            {
                success = true,
                found = true,
                record = new
                {
                    key = record.Key,
                    value = record.Value,
                    data = record.Data
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao executar LookupByCode: {Code}", request.Code);
            return StatusCode(500, new { success = false, error = ex.Message });
        }
    }

    /// <summary>
    /// Retorna os campos protegidos de uma tabela.
    /// GET /Form/GetProtectedFields?tableId={id}
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetProtectedFields(int tableId)
    {
        try
        {
            var protectedFields = await _validationService.GetProtectedFieldsAsync(tableId);
            return Json(new
            {
                success = true,
                fields = protectedFields.Select(f => new
                {
                    fieldName = f.FieldName,
                    label = f.Label,
                    componentType = f.ComponentType,
                    reason = f.Reason.ToString(),
                    isApAtField = f.IsApAtField,
                    isMarcCamp = f.IsMarcCamp
                })
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter campos protegidos da tabela {TableId}", tableId);
            return StatusCode(500, new { success = false, error = ex.Message });
        }
    }

    /// <summary>
    /// Valida se modificações em campos protegidos são permitidas.
    /// POST /Form/ValidateModifications
    /// Body: { tableId, originalData, newData }
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> ValidateModifications([FromBody] ValidateModificationsRequest request)
    {
        try
        {
            // Verifica se o registro está finalizado
            var isFinalized = await _validationService.IsRecordFinalizedAsync(
                request.TableId, request.OriginalData);

            // Valida modificações
            var result = await _validationService.ValidateModificationsAsync(
                request.TableId,
                request.OriginalData,
                request.NewData,
                isFinalized);

            if (result.IsValid)
            {
                return Json(new { success = true, isValid = true });
            }
            else
            {
                return Json(new
                {
                    success = true,
                    isValid = false,
                    isFinalized,
                    message = result.SummaryMessage,
                    violations = result.Violations.Select(v => new
                    {
                        fieldName = v.FieldName,
                        label = v.Label,
                        originalValue = v.OriginalValue?.ToString(),
                        newValue = v.NewValue?.ToString(),
                        reason = v.Reason.ToString(),
                        errorMessage = v.ErrorMessage
                    })
                });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao validar modificações da tabela {TableId}", request.TableId);
            return StatusCode(500, new { success = false, error = ex.Message });
        }
    }

    #endregion

    #region Movement Form HTML

    /// <summary>
    /// Retorna o HTML renderizado do formulário de movimento (para o modal).
    /// GET /Form/MovementFormHtml/{tableId}?recordId={recordId}
    /// </summary>
    [HttpGet]
    [Route("Form/MovementFormHtml/{tableId}")]
    public async Task<IActionResult> MovementFormHtml(int tableId, int? recordId = null)
    {
        try
        {
            // Carrega metadados dos campos do movimento
            var fields = await _metadataService.GetMovementFieldsAsync(tableId);

            // Carrega lookups para campos que precisam (tipos T, IT, L, IL)
            var lookupTypes = new[] { "T", "IT", "L", "IL" };
            foreach (var field in fields)
            {
                var compType = field.CompCamp?.ToUpper()?.Trim();
                if (lookupTypes.Contains(compType) && !string.IsNullOrEmpty(field.SqlCamp))
                {
                    try
                    {
                        field.LookupOptions = await _lookupService.ExecuteLookupQueryAsync(field.SqlCamp);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Erro ao carregar lookup para campo {Campo}", field.NomeCamp);
                    }
                }
            }

            // Se tiver recordId, carrega os dados do registro
            Dictionary<string, object?>? recordData = null;
            if (recordId.HasValue)
            {
                recordData = await _consultaService.GetRecordByIdAsync(tableId, recordId.Value);
            }

            // Monta o model para a view
            var model = new MovementFormViewModel
            {
                TableId = tableId,
                RecordId = recordId,
                Fields = fields.Where(f => !f.IsHidden && f.GetComponentType() != ComponentType.Bevel).ToList(),
                RecordData = recordData
            };

            return PartialView("_MovementFormContent", model);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao renderizar formulário de movimento {TableId}", tableId);
            return Content($"<div class=\"alert alert-danger\">Erro ao carregar formulário: {ex.Message}</div>");
        }
    }

    #endregion
}

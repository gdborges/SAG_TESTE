<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# SAG POC Web Application

## Overview

This is a proof-of-concept web application that replicates the functionality of the SAG Delphi ERP system. It uses ASP.NET Core MVC with Razor views, Dapper ORM, and supports both SQL Server and Oracle databases.

## Key Features

### 1. Dynamic Form Rendering
- Forms are rendered dynamically based on metadata from SISTTABE and SISTCAMP tables
- Field types, labels, sizes, and positions come from database metadata
- Supports tabs (GuiaCamp), field ordering (OrdeCamp), and multiple layouts

### 2. Movement System (Movimentos)
The movement system handles 1:N parent-child relationships (e.g., Invoice -> Invoice Items).

#### Architecture
- **MetadataService**: Loads movement metadata from SISTTABE using CabeTabe (parent) and SeriTabe (display mode)
- **MovementService**: CRUD operations for movement records with PK strategy support
- **MovementController**: REST API endpoints for movement operations
- **movement-manager.js**: Client-side JavaScript module for grid management and modal handling

#### Key Tables
- `SISTTABE.CABETABE`: Parent table code (links child to parent)
- `SISTTABE.SERITABE`: Display mode (>50 = inline, <=50 = separate tab)
- `SISTTABE.GETATABE`: Indicates table can have child movements

#### Movement Component Names (Delphi -> Web)
| Delphi Component | Web Selector |
|------------------|--------------|
| DBG\<N\> | `[data-movement-table="<N>"]` |
| BTNNOV\<N\> | `[data-movement-add="<N>"]` |
| BTNALT\<N\> | `[data-movement-edit="<N>"]` |
| BTNEXC\<N\> | `[data-movement-delete="<N>"]` |
| PNLMOV\<N\> | `[data-movement-panel="<N>"]` |

#### Movement Events
- `AnteIAE_Movi_<CodiTabe>`: Before any Insert/Alter/Exclude
- `AnteIncl_<CodiTabe>`: Before Insert
- `DepoIncl_<CodiTabe>`: After Insert
- `AtuaGrid_<CodiTabe>`: After grid refresh

### 3. PLSAG Interpreter
Custom scripting language that executes database-stored instructions.

#### Template Variables
- `{D-Campo}`: Header record field value
- `{DM-Campo}`: Movement record field value
- `{D2-Campo}`: Sub-movement record field value
- `{P-Campo}`: Parameter value

#### Common Commands
- `ED,<component>,ENABLED,<0|1>`: Enable/disable component
- `ED,<component>,VISIBLE,<0|1>`: Show/hide component
- `ESI,<table>,<pk>,<sql>`: Execute SQL and load into form
- `MSG,<type>,<message>`: Display message
- `WH,<condition>,<instructions>`: While loop
- `IF,<condition>,<then>,<else>`: Conditional

### 4. Consulta System
Grid-based data lookup with search, pagination, and row selection.

## Project Structure

```
SagPoc.Web/
├── Controllers/
│   ├── FormController.cs      # Main form rendering
│   ├── MovementController.cs  # Movement REST API
│   └── PlsagController.cs     # PLSAG execution API
├── Services/
│   ├── Database/
│   │   ├── IDbProvider.cs     # Database abstraction
│   │   ├── SqlServerProvider.cs
│   │   └── OracleProvider.cs
│   ├── MetadataService.cs     # Table/field metadata
│   ├── MovementService.cs     # Movement CRUD
│   ├── ConsultaService.cs     # Record CRUD
│   ├── LookupService.cs       # Lookup tables
│   └── EventService.cs        # PLSAG events
├── Models/
│   ├── FormMetadata.cs        # Form configuration
│   ├── TableMetadata.cs       # Table metadata
│   ├── MovementMetadata.cs    # Movement hierarchy
│   └── FieldMetadata.cs       # Field configuration
├── Views/Form/
│   ├── Render.cshtml          # Main form view
│   ├── _FormContent.cshtml    # Form fields
│   ├── _MovementSection.cshtml # Movement container
│   ├── _MovementGrid.cshtml   # Movement data grid
│   └── _MovementModal.cshtml  # Movement edit modal
└── wwwroot/js/
    ├── plsag-interpreter.js   # PLSAG parser/executor
    ├── plsag-commands.js      # PLSAG command implementations
    ├── movement-manager.js    # Movement grid/modal manager
    ├── sag-events.js          # Event system
    └── consulta-grid.js       # Consulta grid manager
```

## API Endpoints

### Movement API
- `GET /api/movement/{parentId}/tables` - List movement tables for parent
- `GET /api/movement/{parentId}/{tableId}/data` - Get movement grid data
- `GET /api/movement/{tableId}/form/{recordId}` - Get record for editing
- `POST /api/movement/{tableId}` - Insert new movement record
- `PUT /api/movement/{tableId}/{recordId}` - Update movement record
- `DELETE /api/movement/{tableId}/{recordId}` - Delete movement record

### PLSAG API
- `POST /api/plsag/execute` - Execute PLSAG instructions

### Form API
- `GET /Form/Index/{tableId}` - Render form for table
- `GET /Form/GetConsultas?tableId={id}` - Get consulta configurations
- `POST /Form/Save` - Save header record

## Database Configuration

Configure in `appsettings.json`:

```json
{
  "DatabaseProvider": "SqlServer",  // or "Oracle"
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=...;..."
  }
}
```
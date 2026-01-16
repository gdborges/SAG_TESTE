# SAG POC Web - Briefing do Projeto

## Resumo do Projeto

O **SAG POC Web** é uma Prova de Conceito (POC) para migrar o sistema SAG (Sistema de Administração Geral) do Delphi para uma aplicação web moderna utilizando **ASP.NET Core MVC (.NET 9)**.

### Objetivo Principal
Recriar a experiência do sistema desktop SAG em ambiente web, mantendo:
- Renderização dinâmica de formulários baseada em metadados (tabelas SISTTABE, SISTCAMP, etc.)
- Execução de eventos PLSAG (linguagem de script proprietária) no browser
- Grid de consulta com CRUD completo
- Design System Vision (padrão visual da empresa)

### Arquitetura

```
SagPoc.Web/
├── Controllers/        # FormController, PlsagController, ConsultaController
├── Models/            # FormMetadata, FieldMetadata, EventMetadata
├── Services/          # MetadataService, ConsultaService, PlsagService
├── Views/             # Razor views com componentes dinâmicos
└── wwwroot/
    ├── css/           # vision-design-system.css
    └── js/            # plsag-interpreter.js, sag-events.js, consulta-grid.js
```

### Tecnologias
- **Backend:** ASP.NET Core MVC (.NET 9)
- **Frontend:** JavaScript vanilla + CSS (Design System Vision)
- **Banco de Dados:** SQL Server (192.168.0.245\SQL19)
- **Metadados:** Tabelas SISTTABE, SISTCAMP, SISTCons no SQL Server

### Funcionalidades Implementadas
- Renderização dinâmica de formulários por CodiTabe
- Campos: texto, numérico, data, checkbox, combobox, lookup (T/IT)
- Sistema de abas (GuiaCamp)
- Grid de consulta com busca e paginação
- CRUD completo (INSERT, UPDATE, DELETE)
- Interpretador PLSAG no browser (comandos: ESI, VAR, SE/FI, ASSPROP, etc.)
- Eventos de formulário (OnShow, OnExit, OnChange, etc.)

---

## Últimos Ajustes

> **Esta seção deve ser atualizada a cada commit!**

### Commit Atual: `88f2cec` (27/12/2024)

**fix: corrige INSERT/EDIT com triggers e PK dinâmica**

- `ConsultaService`: usa `SCOPE_IDENTITY()` em vez de `OUTPUT INSERTED` para compatibilidade com tabelas que têm triggers (ex: POCALESI)
- `MetadataService`: busca `GravTabe` e `SIGLTABE` do SISTTABE para calcular corretamente o nome da coluna PK (CODI + SIGLTABE)
- `FormMetadata`: adiciona `SiglTabe` e atualiza `PkColumnName`
- `_FormContent`: adiciona `data-pk-field` para rastrear PK no form
- `sag-events`: implementa `onRecordLoaded` para executar eventos de campo ao editar (similar ao onshow do Delphi)
- `consulta-grid`: chama `onRecordLoaded` após carregar registro
- `plsag-interpreter`: adiciona `setInsertMode/isInsertMode` API

### Commits Recentes

| Commit | Descrição |
|--------|-----------|
| `074cf25` | feat: implementa WH loop e atualiza tasks PLSAG |
| `38b9b5d` | feat: adiciona comandos baixa prioridade e fix SQL templates NULL |
| `98f8158` | feat: implementa interpretador PLSAG para execução de eventos no browser |
| `8d5c07d` | refactor: reorganiza estrutura do projeto e remove duplicações |
| `87d57cf` | feat: completa eventos de formulário PLSAG (DepoShow, AtuaGrid, AposTabe) |

---

## Como Executar o Projeto

### Pré-requisitos

1. **.NET 9 SDK** instalado
   ```bash
   # Verificar instalação
   dotnet --version
   ```

2. **SQL Server** acessível (192.168.0.245\SQL19)
   - Database: SAG
   - User: SAG / Password: sag

### Passo a Passo

1. **Clonar o repositório** (se ainda não tiver)
   ```bash
   git clone <url-do-repositório>
   cd SAG
   ```

2. **Navegar para a pasta do projeto**
   ```bash
   cd SagPoc.Web
   ```

3. **Restaurar dependências**
   ```bash
   dotnet restore
   ```

4. **Compilar o projeto**
   ```bash
   dotnet build
   ```

5. **Executar a aplicação**
   ```bash
   dotnet run --urls=http://localhost:5255
   ```

6. **Acessar no navegador**
   ```
   http://localhost:5255/Form/Index/715
   ```
   - Substitua `715` pelo CodiTabe do formulário desejado

### Comandos Úteis

```bash
# Compilar em modo Release
dotnet build -c Release

# Publicar para deploy
dotnet publish -c Release -o ./publish

# Rodar com hot-reload (desenvolvimento)
dotnet watch run

# Limpar builds anteriores
dotnet clean
```

### Troubleshooting

| Problema | Solução |
|----------|---------|
| Erro de conexão SQL Server | Verificar se o servidor está acessível e as credenciais estão corretas em `appsettings.json` |
| Formulário não carrega | Verificar se SISTTABE/SISTCAMP contém metadados do CodiTabe |
| Porta 5255 em uso | Usar `--urls=http://localhost:OUTRA_PORTA` ou matar processo com `taskkill /F /IM dotnet.exe` |

---

## Links Úteis

- **Design System Vision:** Ver `wwwroot/css/vision-design-system.css`
- **Documentação PLSAG:** Ver `openspec/` e comentários em `plsag-interpreter.js`
- **Metadados SQL Server:** Tabelas SISTTABE, SISTCAMP, SISTCons, SISTFILT

---

*Última atualização: 27/12/2024*

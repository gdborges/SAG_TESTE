# [FRONTEND] Vision - CAD324 - Cadastro de Tipos de Equipamentos

Descrição:

Foi criada na API do Core a entidade EquipmentType. O desenvolvedor deverá criar, no módulo de Registro, a tela CAD324 - Cadastro de Tipos de Equipamentos, realizando o consumo dos dados expostos pela API.

🗂️ **Mapeamento de Campos (Frontend ↔ Backend)**

| Campo Frontend | Campo Backend | Tipo/Dados | Obrigatório | Regras/Validações Específicas |
|---|---|---|---|---|
| `Código` | `code` | Numérico | Sim (Automático) | O campo não deve ser editável. |
| `Desc. Tipo Equipamento` | `description` | Texto | Sim | - |
| `Cód. Externo` | `externalCode` | Texto | Não | - |
| `Tipo Equipamento` | `equipmentType` | Lista de Seleção | Sim | Deve apresentar a lista de tipos funcionais de equipamento. |


🚀 **Ações**
- **Incluir**: Ao clicar no botão "Incluir", o usuário é levado para a inserção de um novo registro.
- **Alterar**: O usuário seleciona um registro no Grid e pode visualizar e modificar as informações.
- **Excluir**: Remove o registro selecionado no Grid, sujeito às validações de registro fixo.
- **Gravar**: Salva as alterações (inclusão ou edição).
- **Cancelar**: Descarta as alterações feitas e retorna ao modo de visualização.

✅ **Critérios de Aceitação**
- A interface deve ser responsiva e clara.
- Todas as validações de campos obrigatórios devem funcionar corretamente.
- As mensagens de erro para registros fixos e duplicidade de tipos especiais devem ser exibidas corretamente.
- A lista de seleção para "Tipo Equipamento" deve ser carregada com todas as opções disponíveis.

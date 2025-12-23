# [FRONTEND] Vision - CAD031 - Cadastro de Tipos de Logradouro

🎯 **Descrição**

- Foi criada na API do Core a entidade StreetType. O desenvolvedor deverá criar, no módulo de Registro, a tela CAD031 - Cadastro de Tipos de Logradouro, realizando o consumo dos dados expostos pela API.

🗂️ **Mapeamento de Campos (Frontend ↔ Backend)**

| Campo Frontend | Campo Backend | Tipo/Dados | Obrigatório | Regras/Validações Específicas |
|----------------|---------------|------------|-------------|-------------------------------|
| `Código` | `code` | Numérico | Sim (Automático) | O campo é gerado pelo sistema e não é editável. |
| `Descrição do Tipo de Logradouro` | `description` | Texto | Sim | - |
| `Registro Fixo` | `isFixed` | Checkbox | Sim | Valores: 'S' (marcado), 'N' (desmarcado). Se for fixo, a exclusão é bloqueada. |

🚀 **Ações**
- **Incluir**: Ao clicar no botão "Incluir", o usuário é levado para a inserção de um novo registro.
- **Alterar**: O usuário seleciona um registro no Grid e pode visualizar e modificar as informações.
- **Excluir**: Remove o registro selecionado no Grid, sujeito às validações de registro fixo.
- **Gravar**: Salva as alterações (inclusão ou edição).
- **Cancelar**: Descarta as alterações feitas e retorna ao modo de visualização.

✅ **Critérios de Aceitação**
- Todos os campos obrigatórios validados na tela.
- Registros fixos não podem ser excluídos.
- Mensagens de erro e sucesso são exibidas adequadamente.

⏱️ **Esforço Estimado**
- Frontend: 8 pontos (CRUD, regras, validações, campos específicos)
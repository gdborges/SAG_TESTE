# [FRONTEND] Vision - CAD050 - Cadastro de Classificações de Carga

🎯 **Descrição**

- Foi criada na API do Core a entidade LoadClassifications. O desenvolvedor deverá criar, no módulo de Registro, a tela CAD050 - Cadastro de Classificações de Carga, realizando o consumo dos dados expostos pela API.

## 🗂️ Mapeamento de Campos (Frontend ↔ Backend)

| Campo Frontend                        | Campo Backend                    | Tipo/Dados            | Obrigatório       | Regras/Validações Específicas                                                                 |
|---------------------------------------|----------------------------------|-----------------------|------------------|-----------------------------------------------------------------------------------------------|
| **Código**                            | `code`                | Numérico              | Sim (Automático) | O campo é gerado pelo sistema e **não é editável**.                                           |
| **Descrição**                         | `description`                | Texto (40)            | Sim              | O campo deve ser preenchido.                                                                  |
| **Permite Geração Múltipla de MDF-e?**| `allowMultipleGeneration`    | Select ('Sim'/'Não')  | Sim              | Define o comportamento fiscal para esta classificação.                                        |

---

## 🚦 Regras de UI e Validações

- **Campo Obrigatório**:  
  O campo **Descrição** é de preenchimento obrigatório.  
  - Se não preenchido, o sistema deve exibir mensagem de alerta: `SMsgCampoObrigatorio`.

- **Exclusão de Registro Fixo**:  
  Ao tentar excluir uma classificação que seja fixa (`isFixed = true`), o sistema deve exibir mensagem de erro: `SMsgRegistroFixo` e impedir a exclusão.

- **Confirmação de Exclusão**:  
  Antes de excluir um registro que não seja fixo, o sistema deve solicitar confirmação do usuário com mensagem: `SMsgConfirmaExclusao`.

---

## 🚀 Ações

- **Incluir**: Limpa o formulário de **Detalhes** para inserção de um novo registro.  
- **Excluir**: Remove o registro selecionado, após validação (não fixo) e confirmação.  
- **Gravar**: Salva as alterações (inclusão ou edição) do registro.  
- **Cancelar**: Descarta as alterações feitas no registro em edição/inclusão.  

---

## ✅ Critérios de Aceitação

- A interface deve permitir **criação, edição, visualização e exclusão** de classificações de carga.  
- A validação de **campo obrigatório (Descrição)** deve funcionar corretamente.  
- O **bloqueio de exclusão para registros fixos** deve estar implementado.  
- O fluxo de **CRUD** deve ser **intuitivo e funcional**.  
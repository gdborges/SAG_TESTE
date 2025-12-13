# 🚚 CAD145 - Cadastro Motorista x Transportador

🎯 **Descrição**

- Foi criada na API do Core a entidade DriverOrCarrier. O desenvolvedor deverá criar, no módulo de Registro, a tela CAD145 - Cadastro Motorista x Transportador, realizando o consumo dos dados expostos pela API.

---

## 🗂️ Mapeamento de Campos (Frontend ↔ Backend)

| Campo Frontend        | Campo Backend                   | Tipo/Dados  | Obrigatório | Regras/Validações Específicas                                                                 |
|-----------------------|---------------------------------|-------------|-------------|-----------------------------------------------------------------------------------------------|
| **Código**            | `code`               | Inteiro     | Sim         | Apenas exibição, não editável.                                                                |
| **Cód. Motorista**    | `driverCode`                   | Inteiro     | Sim         | Input com busca (lookup) para o cadastro de motoristas.                                       |
| **Nome Motorista**    | `driverName`                   | Texto       | Não         | Apenas exibição, preenchido após seleção do motorista.                                        |
| **Cód. Transportador**| `carrierCode`   | Inteiro     | Sim         | Input com busca (lookup) para o cadastro de transportadores.                                  |
| **Nome Transportador**| `carrierName`                 | Texto       | Não         | Apenas exibição, preenchido após seleção do transportador.                                    |
| **Ativo (S/N)?**      | `isActive`           | Char(1)     | Sim         | ComboBox/Select com as opções **"Sim"** e **"Não"**.                                          |

---

## 🚦 Regras de UI e Validações

- **Validação de Campos Obrigatórios**  
  - Os campos **Cód. Motorista**, **Cód. Transportador** e **Ativo (S/N)?** devem ser obrigatórios.  
  - O botão **Salvar** só deve ser habilitado após o preenchimento desses campos.  

- **Campos de Exibição**  
  - **Código**, **Nome Motorista** e **Nome Transportador** são apenas leitura e devem estar desabilitados.  

- **Preenchimento Automático**  
  - Ao selecionar motorista/transportador no **lookup**, os campos de nome correspondentes devem ser preenchidos automaticamente.  

- **Inclusão vs. Edição**  
  - Em **inclusão**: campos de código (**Cód. Motorista**, **Cód. Transportador**) editáveis.  
  - Em **edição**: campos de código bloqueados.  

- **Feedback ao Usuário**  
  - Mensagens claras de sucesso ou erro após salvar, excluir ou falhas de validação do backend (ex: *"Relação já cadastrada"*).  

---

## ✅ Critérios de Aceitação

- A pesquisa deve filtrar os vínculos no grid conforme critérios.  
- O formulário deve validar obrigatórios antes do envio.  
- As operações de **CRUD** (Incluir, Editar, Excluir) devem funcionar corretamente, integradas ao backend.  
- Mensagens de feedback claras e consistentes devem ser exibidas.  

---
Você é um especialista em Vue.js 3 e TypeScript atuando no projeto atual. Sua missão é gerar um CRUD completo conforme os padrões internos da aplicação, com base nos parâmetros fornecidos ou extraídos de um card/arquivo de requisitos.

**IMPORTANTE:** 
- Antes de iniciar, analise o arquivo `README.md` na raiz do projeto para entender a estrutura completa do projeto, suas dependências, padrões de organização e convenções utilizadas.
- **TOME SEU TEMPO**: Execute cada passo com máxima atenção e cuidado. Não há pressa - a qualidade é mais importante que velocidade.
- **TODOS OS PASSOS SÃO OBRIGATÓRIOS**: Não pule nenhuma etapa do plano de execução.

### Modo de Operação:

**OPÇÃO A - Parâmetros Diretos:** Solicite os parâmetros listados abaixo.

**OPÇÃO B - Extração de Card/Arquivo:** Se for fornecido um arquivo ou card de requisitos, extraia automaticamente as informações necessárias seguindo estas regras:

#### Regras de Extração:
1. **Interface/Entidade**: Identifique o nome principal da entidade no card
2. **Módulo**: Converta descrições em português para inglês seguindo os padrões:
   - "cadastro/cadastros" → "register"
   - "segurança" → "security" 
   - "comercial" → "commercial"
   - "produção" → "production"
   - "financeiro" → "financial"
   - "relatórios" → "reports"
   
3. **Campos**: Extraia de tabelas de mapeamento (Frontend ↔ Backend) ou listas de campos no card
4. **Campos Obrigatórios**: Identifique campos marcados como "Sim" na coluna "Obrigatório" ou descritos como obrigatórios
5. **Tag da Rota**: Procure por códigos como CAD324, PRO107, etc. no título ou início do card
6. **Entidades Secundárias**: Identifique qualquer entidade mencionada além da principal (ex: Branch, User, Company). Essas entidades são importantes para:
   - Consumo de dados através de componentes (Lookup, Select)
   - Criação de abas adicionais
   - Relacionamentos entre entidades

### Parâmetros Necessários:

1. **Nome da interface/entidade** (ex: User, ProductCategory, EquipmentType)  
2. **Nome da API** (ex: core, checklist)  
3. **Nome do módulo** (ex: security, register, commercial)  
4. **Atributos da interface**  
   Informe no formato:  
   - `nome: tipo` (ex: id: string, name: string, createdAt: Date)  

5. **Campos utilizados para criação**  
   Liste os nomes dos campos (entre os atributos informados) que serão exibidos no formulário de criação.

6. **Tag da rota** (ex: PRO107, CAD210, CAD324, etc.)  

7. **Campos que precisam de validação com Zod**  
   Todos os campos obrigatórios identificados devem ter validação Zod (ex: name, email, price)

---

### Após coletar os dados, siga este plano de execução:

**EXECUÇÃO OBRIGATÓRIA**: Execute TODOS os passos na ordem apresentada. Não pule nenhuma etapa.

**CONFIRMAÇÃO DE PROGRESSO**: Após cada passo concluído, confirme explicitamente que foi executado antes de prosseguir para o próximo.

**REGRA DE FIDELIDADE AOS TEMPLATES**: 
- SIGA EXATAMENTE os templates dos guias correspondentes
- NÃO INVENTE estruturas diferentes dos templates
- COPIE a estrutura COMPLETA dos arquivos de exemplo
- ADAPTE apenas os nomes de entidades e campos específicos

**REGRA DE EXCEÇÃO**: Se algum dos parâmetros ou payload não for fornecido pelo usuário, pule esse passo específico e prossiga para o próximo na sequência. 

---

## ✅ 0. Análise de Referências e Entidades
**ANTES DE CRIAR QUALQUER ARQUIVO**, execute as seguintes análises:

### **0.1 Análise de Referências Obrigatórias**
**LEIA TODOS OS ARQUIVOS ANTES DE INICIAR QUALQUER CRIAÇÃO**

Analise os seguintes arquivos de referência para entender os padrões, estrutura e nomenclatura:

**Guias de CRUD específicos (OBRIGATÓRIOS - LEIA COMPLETAMENTE):**
- `src/docs/guides/modalUsageGuide.md` - **PRIMEIRO**: Critérios de escolha entre Modal, Panel e TabsPanel
- `src/docs/guides/crudWithModal.md` - Template COMPLETO para CRUDs simples (≤11 campos, sem abas)
- `src/docs/guides/crudWithTabsPanel.md` - Template COMPLETO para CRUDs com abas/guias
- `src/docs/guides/crudWithPanel.md` - Template COMPLETO para CRUDs extensos (>11 campos, sem abas)

**Templates de estrutura (SIGA FIELMENTE):**
- `src/docs/guides/interfaceStructureGuide.md` - Template EXATO para interfaces TypeScript
- `src/docs/guides/serverApiStructureGuide.md` - Template EXATO para services/APIs

**Guias complementares:**
- `src/docs/guides/crudPattern.md` - Padrões gerais
- `src/docs/guides/unitTesting.md` - Padrões de testes
- `src/docs/guides/translationGuide.md` - Estrutura de traduções
- `src/docs/guides/viewStructureGuide.md` - Padrões de views
- `src/docs/guides/crudCommonPatterns.md` - Padrões comuns a todos os tipos

**REGRA CRÍTICA DE ESCOLHA DO COMPONENTE:**
1. **Tem abas/guias mencionadas no card?** → **TabsPanel** (independente da quantidade de campos)
2. **Até 11 campos e sem abas?** → **Modal**
3. **Mais de 11 campos e sem abas?** → **Panel**

### **0.2 Identificação de Entidades Secundárias**
**Se foram identificadas entidades secundárias** (ex: Branch, User, Company), execute:

1. **Localizar interfaces existentes**: Procure em `src/interfaces/api/` por interfaces dessas entidades (nomenclatura em inglês)
2. **Localizar services existentes**: Procure em `src/server/api/` por services dessas entidades
3. **Verificar se existem**: Se não existirem, adicione-as ao plano de criação
4. **Documentar dependências**: Liste quais entidades secundárias serão usadas e onde

**Ação:** Complete ambas as análises antes de prosseguir com a criação dos arquivos.

---

## ✅ 1. Interfaces de resposta  
**Local:** `src/interfaces/api/{api}/{NomeInterface}.ts`  
**Ação:** Crie a interface principal seguindo EXATAMENTE o template em `src/docs/guides/interfaceStructureGuide.md`

**IMPORTANTE**: 
- Use APENAS a estrutura do template
- Substitua apenas os nomes de campos específicos
- Mantenha TODOS os padrões de nomenclatura e tipos

**Se existem entidades secundárias identificadas:**
- Verifique se as interfaces já existem em `src/interfaces/api/`
- Se não existirem, crie as interfaces necessárias seguindo o mesmo padrão
- **Local das secundárias:** `src/interfaces/api/{api-da-entidade}/{NomeEntidadeSecundaria}.ts`

---

## ✅ 2. Endpoints  
**Local:** `src/server/api/{api}/{nomeInterfaceCamelCase}.ts`  
**Ação:** Implemente seguindo EXATAMENTE o template em `src/docs/guides/serverApiStructureGuide.md`

**IMPORTANTE**: 
- Copie a estrutura COMPLETA do template
- Substitua apenas os nomes de entidades
- Mantenha TODOS os 7 endpoints obrigatórios:
  - `GET /` → listar todos  
  - `GET /:id` → obter por id  
  - `POST /` → criar novo  
  - `PUT /:id` → atualizar existente  
  - `DELETE /:id` → remover  
  - `GET /criterios` → buscar critérios  
  - `POST /criterios` → buscar por critérios  

**Se existem entidades secundárias identificadas:**
- Verifique se os services já existem em `src/server/api/`
- Se não existirem, crie os services necessários seguindo o mesmo padrão
- **Local das secundárias:** `src/server/api/{api-da-entidade}/{nomeEntidadeSecundariaCamelCase}.ts`
- Implemente pelo menos os endpoints básicos: `GET /`, `GET /:id`, `GET /criterios`, `POST /criterios`

---

## ✅ 3. Página Vue (View)  
**Local:** `src/views/private/{modulo}/{nome-interface-kebab-case}.vue`  

**IMPORTANTE - NOMENCLATURA DE ARQUIVOS:**
- **SEMPRE use kebab-case** para nomes de arquivos na pasta `views`
- Exemplo correto: `payment-method.vue`, `user-profile.vue`, `product-category.vue`
- Exemplo INCORRETO: `PaymentMethod.vue`, `UserProfile.vue`, `ProductCategory.vue`
- **REGRA**: Converta PascalCase para kebab-case (PaymentMethod → payment-method)

**Ação:** Crie a página seguindo EXATAMENTE o template do componente escolhido:

**DECISÃO DO COMPONENTE (baseada na análise do card):**
- **Se tem abas/guias:** Use template `src/docs/guides/crudWithTabsPanel.md`
- **Se ≤11 campos sem abas:** Use template `src/docs/guides/crudWithModal.md`
- **Se >11 campos sem abas:** Use template `src/docs/guides/crudWithPanel.md`

**IMPORTANTE**: 
- Copie a estrutura COMPLETA do template escolhido
- Substitua apenas nomes de entidades e campos específicos
- NÃO ALTERE a estrutura base do componente
- Mantenha TODOS os imports, composables e padrões do template

**IMPLEMENTAÇÃO DE COMPONENTES:**
Para implementar os componentes de formulário, consulte OBRIGATORIAMENTE o arquivo:
- `src/docs/guides/componentImplementationGuide.md` - Templates EXATOS para todos os componentes

Obs: alguns componentes não precisam de importação pois são globais para saber quais não precisam de importação, veja o arquivo `src/utils/configs/globalComponents.ts`.

**Mapeamento de Tipos → Componentes:**
| Tipo do Campo | Componente | Consulte no Guia |
|---------------|------------|-------------------|
| `string` / `number` | `FormControl` | Seção "FormControl - Campos de Texto e Número" |
| `Date` | `Datepicker` | Seção "Datepicker - Campos de Data" |
| `boolean` / `enum` | `Select` | Seção "Select - Campos de Seleção" |
| `entity` (relacionamentos) | `Lookup` | Seção "Lookup - Campos de Busca" |
| `Files[]` | `AttachmentField` | Seção "AttachmentField - Campos de Anexo" |
| `Array` | `CustomMultiselect` | Seção "CustomMultiselect - Seleção Múltipla" |

**REGRA CRÍTICA**: Use EXATAMENTE os templates do guia `componentImplementationGuide.md`. NÃO invente implementações diferentes.

Inclua validações com `zod` nos campos obrigatórios indicados. Sempre utilize `v-model` para garantir a reatividade dos campos conforme os padrões do Vue 3.

---

## ✅ 4. Rota  
**Ação:**  
Adicione a rota no arquivo de rotas do módulo correspondente, utilizando a **tag fornecida** e respeitando a ordem numérica e ordenação alfabética.

---

## ✅ 5. Traduções  
**Idiomas utilizados:** `pt-br`, `en-us`, `es-es`  
**Ação:** Crie ou atualize os seguintes arquivos de tradução, baseando-se no módulo e na tag da rota:

- `src/translations/locales/{idioma}/{modulo}/entities.json`  
- `src/translations/locales/{idioma}/{modulo}/errors.json`  
- `src/translations/locales/{idioma}/{modulo}/labels.json`  
- `src/translations/locales/{idioma}/routes.json`  

Inclua chaves de tradução para:  
- Nome da interface  
- Rótulos dos campos  
- Mensagens de erro  
- Nome da rota para exibição em menus  

---

## ✅ 6. Testes unitários   
**Ação:** Crie ou atualize o arquivo de testes unitários:

- `src/views/private/{modulo}/tests/{nome-interface}.spec.ts`  
- `src/server/api/tests/{nomeInterface}.spec.ts`  

Inclua testes para:  
- Teste da montagem do componente
- Teste da criação do crud completo 
- Teste da validações 
- Teste da rotas 
- Teste da traduções 

Obs: Não precisa executar os testes unitários no final da criação.

---

## ✅ CHECKLIST DE VERIFICAÇÃO FINAL
**ANTES DE FINALIZAR**, confirme que TODOS os passos foram executados:

- [ ] **Passo 0.1**: Analisou todas as referências obrigatórias
- [ ] **Passo 0.2**: Identificou e localizou entidades secundárias (se existirem)
- [ ] **Passo 1**: Criou a interface TypeScript principal (+ interfaces secundárias se necessário)
- [ ] **Passo 2**: Implementou todos os 7 endpoints da API principal (+ endpoints secundários se necessário)
- [ ] **Passo 3**: Criou a página Vue com a estrutura correta com base no template escolhido (+ tabs se necessário)
- [ ] **Passo 4**: Adicionou a rota corretamente no arquivo de rota do módulo
- [ ] **Passo 5**: Criou traduções para os 3 idiomas (pt-br, en-us, es-es)
- [ ] **Passo 6**: Criou arquivo de testes unitários

**VERIFICAÇÃO DE ENTIDADES SECUNDÁRIAS:**
- [ ] Todas as entidades secundárias identificadas possuem interfaces
- [ ] Todas as entidades secundárias identificadas possuem services
- [ ] Componentes que dependem de entidades secundárias estão configurados corretamente

**ATENÇÃO**: Se algum item não foi concluído, VOLTE e execute o passo faltante. Não finalize sem completar todos os itens.

---

## 📝 Observações finais:
- Nome da interface: **PascalCase** (ex: PaymentMethod, UserProfile)  
- Nome da API: **camelCase** (ex: paymentMethod, userProfile)  
- **Nome do arquivo da view: SEMPRE kebab-case** (ex: payment-method.vue, user-profile.vue)  
- **CRÍTICO**: Arquivos na pasta `views` NUNCA devem usar PascalCase ou camelCase
- Zod deve ser usado apenas nos campos informados como obrigatórios  
- A ordem das tags de rota deve ser respeitada  
- Sempre crie uma estrutura padrão com:
  - Grid para listagem com paginação
  - Modal para criação/edição
  - Tratamento de erros

Após reunir os dados, gere automaticamente os arquivos e estruturas conforme descrito, seguindo as práticas e padrões indicados nos arquivos de referência.

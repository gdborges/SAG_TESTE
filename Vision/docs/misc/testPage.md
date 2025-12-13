# Página de Teste (Test Page)

## Visão Geral

A página de teste (`test-page.vue`) é um ambiente de desenvolvimento dedicado para testar e demonstrar componentes e suas variações dentro do sistema. Esta página serve como um playground para desenvolvedores testarem novos componentes, verificarem diferentes configurações e garantirem que os componentes funcionem conforme esperado antes de serem integrados em páginas de produção.

## Localização

```
src/views/private/test-page.vue
```

## Propósito

- **Ambiente de Testes**: Fornece um espaço isolado para testar componentes sem afetar páginas de produção
- **Demonstração de Componentes**: Exibe diferentes variações e configurações dos componentes
- **Prototipagem Rápida**: Permite implementar e testar rapidamente novos componentes ou recursos
- **Documentação Visual**: Serve como referência visual para desenvolvedores entenderem como usar os componentes

## Componentes Demonstrados

A página de teste atualmente demonstra os seguintes componentes:

### TreeListSelect

O componente `TreeListSelect` é demonstrado com diferentes configurações:

- **Versão Básica**: Demonstração do componente com itens simples
- **Com Segmentação**: Demonstração com itens organizados em segmentos (categorias)
- **Com Limite de Seleção**: Demonstração com limite máximo de itens selecionáveis
- **Estado de Erro**: Demonstração do componente em estado de erro
- **Estado Desabilitado**: Demonstração do componente desabilitado

### TreeListSelection

O componente `TreeListSelection` é demonstrado como parte de uma integração com AG Grid, mostrando como ele pode ser usado em células de grid para seleção de múltiplos itens.

## Como Usar a Página de Teste

1. **Adicionar Novos Componentes**: Para testar um novo componente, importe-o e adicione-o à página com as configurações desejadas
2. **Testar Variações**: Crie diferentes instâncias do mesmo componente com configurações variadas para testar todos os casos de uso
3. **Verificar Comportamento**: Interaja com os componentes para verificar se o comportamento está conforme esperado
4. **Documentar Exemplos**: Use os exemplos como referência para documentar como usar os componentes

## Boas Práticas

- Mantenha a página organizada, agrupando componentes relacionados
- Adicione comentários explicativos para configurações complexas
- Use dados de teste realistas para simular casos de uso reais
- Teste casos extremos (valores vazios, muitos itens, etc.)
- Verifique a responsividade dos componentes em diferentes tamanhos de tela

## Exemplo de Implementação

Para adicionar um novo componente à página de teste:

```vue
<template>
  <div class="test-section">
    <h3>Teste do Novo Componente</h3>
    
    <div class="test-case">
      <h4>Configuração Básica</h4>
      <NovoComponente 
        :prop1="valor1"
        :prop2="valor2"
      />
    </div>
    
    <div class="test-case">
      <h4>Com Estado de Erro</h4>
      <NovoComponente 
        :prop1="valor1"
        :prop2="valor2"
        :error="true"
        help-text="Mensagem de erro de exemplo"
      />
    </div>
  </div>
</template>
```

## Conclusão

A página de teste é uma ferramenta essencial para o desenvolvimento e manutenção de componentes de alta qualidade. Ela permite que os desenvolvedores testem e refinem componentes em um ambiente controlado antes de integrá-los às páginas de produção, garantindo uma experiência de usuário consistente e livre de erros.

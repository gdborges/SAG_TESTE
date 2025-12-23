# Guia de Estrutura de Interface - Entity.ts

### Localização
```
src/interfaces/api/{modulo}/{Entity}.ts
```

**Nota**: A localização do arquivo vai depender de qual API os endpoints foram criados, podendo mudar de um módulo para outro conforme a organização dos endpoints no backend.

## Template Base

```typescript
interface Entity {
  // Adicione aqui os campos específicos da sua entidade com os tipos
  specificField1: string;
  specificField2: number | null;
}

export type {
  //exportar as interfaces no final do arquivo
  Entity,
}
```

## Convenções

### Nomenclatura
- **Interfaces**: PascalCase (`Entity`)
- **Campos**: camelCase (`specificField`, `isActive`)
- **IDs**: Terminam com `Id` (`categoryId`)
- **Flags**: Começam com `is` (`isActive`)

### Tipos de Dados
- **IDs**: `string`
- **Códigos**: `number`
- **Textos**: `string` ou `string | null`
- **Flags**: `boolean`
- **Datas**: `string` (ISO format)

### Campos Obrigatórios
- **Opcionais**: Com `| null`
# Guia de Estrutura de Server/API - entity.ts

## Visão Geral

Este guia define o padrão para criação de serviços de API no projeto, baseado na estrutura estabelecida pelos arquivos existentes. Use este template como base para criar novos serviços de entidades.

## Estrutura do Arquivo

### Localização
```
src/server/api/{modulo}/entity.ts
```

**Nota**: A localização do arquivo vai depender de qual API os endpoints foram criados, podendo mudar de um módulo para outro conforme a organização dos endpoints no backend.

### Template Base

```typescript
import { Service, useFetch } from "../../../composables/useFetch";
import { HttpResponse } from "../../../interfaces/Http";
import { ColumnGrid } from "../../../interfaces/api/custom/Template";
import { Entity, EntitySummary } from "../../../interfaces/api/{modulo}/Entity";

export function useEntityService() {
  const { fetchData, error, result, loading } = useFetch(Service.{Modulo});
  
  const getEntities = async (params = ''): HttpResponse<Entity[]> => {
    // IMPORTANTE: Caso a entity tenha duas palavras, coloque na rota em camelCase
    // Exemplo: /entityName
    await fetchData('get', `/entity?${params}`);
    return {
      error,
      result
    };
  };

  const getEntity = async (id: string): HttpResponse<Entity> => {
    await fetchData('get', `/entity/${id}`);
    return {
      error,
      result
    };
  };

  const createEntity = async (payloadToCreate: Partial<Entity> | Entity): HttpResponse<Entity> => {
    await fetchData('post', '/entity/', payloadToCreate);
    return {
      error,
      result
    };
  };

  const updateEntity = async (id: number | string, payloadToUpdate: Entity): HttpResponse<Entity> => {
    await fetchData('put', `/entity/${id}`, payloadToUpdate);
    return {
      error,
      result
    };
  };

  const deleteEntity = async (id: number | string): HttpResponse<Entity> => {
    await fetchData('delete', `/entity/${id}`);
    return {
      error,
      result
    };
  };
  
  const getEntitiesByCriteria = async (params = '', payload: object): HttpResponse<Entity[]> => {
    await fetchData('post', `/entity/filter?${params}`, payload);
    return {
      error,
      result
    };
  };

  const getEntityCriteria = async (): HttpResponse<ColumnGrid[]> => {
    await fetchData('get', `/entity/criteria`);
    return {
      error,
      result
    };
  };

  
  return {
    getEntities,
    getEntity,
    createEntity,
    updateEntity,
    deleteEntity,
    getEntitiesByCriteria,
    getEntityCriteria,
    loading,
  };
}
```

## Convenções

### Nomenclatura
- **Nome**: `useEntityService()` 
- **Endpoints**: REST padrão (`/entity`, `/entity/{id}`)
- **Retorno**: `HttpResponse<T>` com `error` e `result`

### Funções Obrigatórias
- `getEntities(params)` - Listar
- `getEntity(id)` - Buscar por ID
- `createEntity(payload)` - Criar
- `updateEntity(id, payload)` - Atualizar
- `deleteEntity(id)` - Remover
- `getEntitiesByCriteria()` - Busca avançada
- `getEntityCriteria()` - Critérios de filtro

# Sistema de Sincronização ClickUp + Supabase

## ✅ Arquitetura Atual (Edge Functions)

O sistema usa **Edge Functions do Supabase** com autenticação integrada, chamadas por **Automações do ClickUp**.

### 🏗️ Estrutura Completa

```
ClickUp Automations
    ↓
Supabase Edge Functions
    ↓
PostgreSQL (Tabelas)
```

### 📊 Tabelas do Sistema

1. **casting** - Tarefas principais
2. **custom_fields_metadata** - Metadados dos campos customizados
3. **sync_logs** - Logs de sincronização
4. **webhook_events** - Eventos recebidos (para logging)
5. **security_audit_logs** - Auditoria de segurança
6. **user_credentials** - Credenciais armazenadas no Vault

### 🔧 Edge Functions Disponíveis

| Function | URL | Descrição |
|----------|-----|-----------|
| `clickup-webhook` | `/functions/v1/clickup-webhook` | Recebe eventos do ClickUp |
| `sync-to-clickup` | `/functions/v1/sync-to-clickup` | Envia dados para ClickUp |
| `sync-cleanup` | `/functions/v1/sync-cleanup` | Marca tarefas inativas |
| `sync-custom-fields` | `/functions/v1/sync-custom-fields` | Sincroniza campos |
| `manage-credentials` | `/functions/v1/manage-credentials` | Gerencia credenciais |
| `security-dashboard` | `/functions/v1/security-dashboard` | Dashboard de segurança |

## 🚀 URLs das Edge Functions

Base URL: `https://cfvxlmnjzojvmdvcukvd.supabase.co`

### Endpoints Completos:
- **Webhook**: `https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/clickup-webhook`
- **Sync to ClickUp**: `https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/sync-to-clickup`
- **Cleanup**: `https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/sync-cleanup`
- **Custom Fields**: `https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/sync-custom-fields`

## 📋 Configuração das Automações no ClickUp

### 1. Automation para Task Created:
```
Trigger: Quando tarefa criada
Condição: Tarefa na lista "Casting Allfluence"
Ação: Webhook de chamada (antigo)
URL: https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/clickup-webhook
Dados: 
- Task ID
- Task Name
- Task Description
- Creator Username
```

### 2. Automation para Task Updated:
```
Trigger: Alterações de campo personalizado
Campo: Resumo (ou outros campos sincronizados)
Ação: Webhook de chamada (antigo)
URL: https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/clickup-webhook
```

## 🧪 Testando o Sistema

### 1. Testar Webhook (PowerShell):
```powershell
$headers = @{
    'Content-Type' = 'application/json'
}

$body = @{
    event = 'taskCreated'
    payload = @{
        id = 'test123'
        name = 'Teste de Webhook'
        status = @{ status = 'to do' }
        custom_fields = @()
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri 'https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/clickup-webhook' -Method POST -Headers $headers -Body $body
```

### 2. Testar Sync Cleanup:
```powershell
Invoke-RestMethod -Uri 'https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/sync-cleanup' -Method POST
```

### 3. Testar Custom Fields Sync:
```powershell
Invoke-RestMethod -Uri 'https://cfvxlmnjzojvmdvcukvd.supabase.co/functions/v1/sync-custom-fields' -Method POST
```

## 🔐 Variáveis de Ambiente (Edge Functions)

Configuradas no Supabase Dashboard:
- `CLICKUP_API_TOKEN` - Token da API do ClickUp
- `CLICKUP_LIST_ID` - ID da lista (9007008605 para Casting)
- `SUPABASE_URL` - URL do projeto
- `SUPABASE_SERVICE_ROLE_KEY` - Chave de serviço

## 📊 Monitoramento

### Ver Logs de Sincronização:
```sql
-- Últimos 10 logs
SELECT * FROM sync_logs 
ORDER BY created_at DESC 
LIMIT 10;

-- Logs de erro
SELECT * FROM sync_logs 
WHERE status = 'error' 
ORDER BY created_at DESC;

-- Resumo por tipo
SELECT 
    direction,
    action,
    status,
    COUNT(*) as total
FROM sync_logs
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY direction, action, status;
```

### Ver Eventos do Webhook:
```sql
-- Últimos eventos recebidos
SELECT * FROM webhook_events 
ORDER BY created_at DESC 
LIMIT 20;

-- Eventos não processados
SELECT * FROM webhook_events 
WHERE processed = false 
ORDER BY created_at;
```

## 🔍 IDs Importantes

- **Lista Casting**: `9007008605`
- **Custom Field supabase_id**: `f39afd90-efe8-4128-9a48-e5e3facdb95a`
- **Projeto Supabase**: `cfvxlmnjzojvmdvcukvd`

## 🆘 Troubleshooting

### 1. Webhook não recebe eventos:
- Verifique as automações no ClickUp
- Confirme a URL está correta
- Veja os logs: `SELECT * FROM sync_logs WHERE action = 'webhook_received'`

### 2. Tarefas não sincronizam:
- Verifique o campo `supabase_id` no ClickUp
- Confirme que `casting_sync = true` nos custom fields
- Veja erros: `SELECT * FROM sync_logs WHERE status = 'error'`

### 3. Custom fields não aparecem:
- Execute sync-custom-fields
- Verifique: `SELECT * FROM custom_fields_metadata WHERE casting_sync = true`

## 📝 Notas Importantes

1. **Auth**: Edge Functions usam Supabase Auth (não precisam de Bearer token)
2. **Rate Limits**: ClickUp API tem limite de 100 req/min
3. **Cleanup**: Executar `sync-cleanup` periodicamente para marcar tarefas deletadas
4. **Custom Fields**: Apenas campos com `casting_sync = true` são sincronizados

---

**Sistema mantido e funcionando com Edge Functions + Automações do ClickUp**

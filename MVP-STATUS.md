# ClickUp Sync - Status do MVP

## ✅ Sistema Funcionando!

O webhook receiver está rodando em produção: https://clickup-sync.allfluence.ai

### Endpoints Disponíveis:
- `GET /` - Página inicial com status
- `GET /health` - Health check
- `POST /webhook` - Receiver para webhooks do ClickUp
- `GET /logs` - Visualizar eventos recebidos

## 🔧 Configuração Pendente

### 1. Criar Tabela no Supabase

Acesse seu projeto Supabase e execute o SQL:

```sql
-- Arquivo: sql/create-webhook-events-table.sql
CREATE TABLE IF NOT EXISTS public.webhook_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_type VARCHAR(255),
    payload JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_webhook_events_created_at ON public.webhook_events(created_at DESC);
CREATE INDEX idx_webhook_events_event_type ON public.webhook_events(event_type);
CREATE INDEX idx_webhook_events_processed ON public.webhook_events(processed);
```

### 2. Configurar Webhook no ClickUp

1. Acesse ClickUp → Settings → Integrations → Webhooks
2. Clique em "Create Webhook"
3. Configure:
   - **Endpoint URL**: `https://clickup-sync.allfluence.ai/webhook`
   - **Events**: Selecione os eventos desejados:
     - taskCreated
     - taskUpdated
     - taskDeleted
     - taskStatusUpdated
     - etc.
4. Salve e teste

## 🧪 Testando o Sistema

### Teste Manual do Webhook:
```powershell
# PowerShell
$headers = @{
    'Content-Type' = 'application/json'
    'x-clickup-event' = 'taskCreated'
}
$body = @{
    task_id = 'test123'
    name = 'Test Task'
} | ConvertTo-Json

Invoke-RestMethod -Uri 'https://clickup-sync.allfluence.ai/webhook' -Method POST -Headers $headers -Body $body
```

### Verificar Logs:
```bash
# Browser ou curl
https://clickup-sync.allfluence.ai/logs
```

## 📊 Arquitetura Atual

```
ClickUp → Webhook → Express Server → Supabase
                          ↓
                    Portainer/Docker
                          ↓
                    Traefik (HTTPS)
```

## 🚀 Próximos Passos

1. ✅ Container rodando
2. ✅ Servidor funcionando
3. ⏳ Criar tabela no Supabase
4. ⏳ Configurar webhook no ClickUp
5. ⏳ Testar fluxo completo
6. 🔄 Implementar processamento dos eventos

## 🔐 Variáveis de Ambiente (Configuradas no Portainer)

- `SUPABASE_URL` ✅
- `SUPABASE_ANON_KEY` ✅
- `CLICKUP_API_KEY` ✅
- `CLICKUP_TEAM_ID` ✅

---

**Status**: Sistema pronto para receber webhooks após criar tabela no Supabase!

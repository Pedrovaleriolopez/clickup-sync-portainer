# ClickUp Sync - Portainer Stack

## 🚀 Deploy no Portainer

### 1. Criar Personal Access Token no GitHub

1. GitHub → Settings → Developer Settings → Personal Access Tokens
2. Fine-grained tokens → Generate new token
3. Repository access: Select repositories → `clickup-sync-portainer`
4. Permissions: Contents → Read
5. Generate token e salve!

### 2. Deploy Stack no Portainer

1. **No Portainer:**
   - Stacks → Add Stack
   - Name: `clickup-sync`
   - Build method: **Repository**
   - Repository Settings:
     - ✅ Authentication toggle ON
     - Username: `Pedrovaleriolopez`
     - Personal Access Token: [seu token]
   - Repository URL: `https://github.com/Pedrovaleriolopez/clickup-sync-portainer`
   - Repository reference: `main`
   - Compose path: `docker-compose.yml`

2. **Environment Variables (adicione no Portainer):**
   ```
   SUPABASE_URL=https://seu-projeto.supabase.co
   SUPABASE_ANON_KEY=sua-chave-anon
   CLICKUP_API_KEY=sua-api-key
   CLICKUP_TEAM_ID=seu-team-id
   ```

3. **Clique em "Deploy the stack"**

### 3. Configurar Webhook no ClickUp

1. ClickUp → Space Settings → Integrations → Webhooks
2. Add Webhook:
   - Endpoint URL: `https://clickup-sync.allfluence.ai/webhook`
   - Events: Selecione os eventos desejados
   - Save

### 4. Criar Tabelas no Supabase

No SQL Editor do Supabase:

```sql
-- Tabela para armazenar eventos do webhook
CREATE TABLE webhook_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela para status de sincronização
CREATE TABLE sync_status (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  clickup_id TEXT UNIQUE,
  supabase_id UUID,
  last_sync TIMESTAMPTZ,
  status TEXT DEFAULT 'pending'
);

-- Enable RLS
ALTER TABLE webhook_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_status ENABLE ROW LEVEL SECURITY;

-- Policy for authenticated users
CREATE POLICY "Enable all for authenticated users"
  ON webhook_events
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable all for authenticated users"
  ON sync_status
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
```

## 📋 Endpoints

- `GET /` - Página inicial com instruções
- `GET /health` - Health check
- `POST /webhook` - Receiver para webhooks do ClickUp
- `GET /logs` - Visualizar últimos 20 eventos recebidos

## 🔄 Atualizar Stack

1. Faça push das mudanças para o GitHub
2. No Portainer: Stack → clickup-sync → Editor
3. Clique em "Update the stack" com "Re-pull image" marcado

## 🐛 Debug

```bash
# Ver logs no Portainer
Stacks → clickup-sync → clickup-sync_app_1 → Logs

# Testar webhook localmente
curl -X POST https://clickup-sync.allfluence.ai/webhook \
  -H "Content-Type: application/json" \
  -H "X-ClickUp-Event: taskCreated" \
  -d '{"task": {"id": "123", "name": "Test"}}'
```

## 📦 Estrutura

```
├── docker-compose.yml   # Stack definition (inline server)
├── README.md           # Este arquivo
└── versions/           # Versões anteriores
    ├── docker-compose.v1-basic.yml
    ├── docker-compose.v2-with-webhook.yml
    └── docker-compose.v3-inline.yml
```

## 🔧 Notas Técnicas

### Correção: npm init em containers reiniciados (25/06/2024)
- **Problema**: Erro "Tracker idealTree already exists" ao reiniciar containers
- **Causa**: `npm init -y` tentava recriar package.json existente
- **Solução**: 
  - Adicionado `working_dir: /app` no compose
  - Verificação condicional antes de `npm init`
  - Mantém dependências entre reinicializações

### Inline Server
- Todo o código do servidor está embutido no docker-compose.yml
- Não requer arquivos externos (server.js, package.json)
- Simplifica deploy e manutenção
- Ideal para projetos simples e POCs
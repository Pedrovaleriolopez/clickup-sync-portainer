#!/bin/bash
# Health Check Script for ClickUp Sync

echo "🔍 Verificando status do ClickUp Sync..."
echo "========================================="

# URL base
BASE_URL="https://clickup-sync.allfluence.ai"

# Health check
echo "📋 Health Check:"
curl -s "${BASE_URL}/health" | jq . || echo "❌ Falha no health check"
echo ""

# Teste de webhook
echo "🪝 Testando webhook:"
RESPONSE=$(curl -s -X POST "${BASE_URL}/webhook" \
  -H "Content-Type: application/json" \
  -H "X-ClickUp-Event: test" \
  -d '{"test": true, "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}'
)
echo "$RESPONSE" | jq . || echo "$RESPONSE"
echo ""

# Verificar logs (últimos eventos)
echo "📜 Últimos eventos (se Supabase configurado):"
curl -s "${BASE_URL}/logs" | jq . || echo "ℹ️  Supabase não configurado ou sem eventos"
echo ""

echo "========================================="
echo "✅ Verificação completa!"
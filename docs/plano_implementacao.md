# Plano de Implementação de Melhorias

Este documento apresenta um plano estruturado para implementar as melhorias identificadas nos documentos de bugs e arquitetura, organizadas por prioridade e complexidade.

## Prioridades de Implementação

### Prioridade 1: Problemas Críticos e Bugs Ativos
- Problemas que afetam diretamente a jogabilidade ou causam crashes
- Bugs visíveis para os usuários finais
- Problemas de segurança ou desempenho graves

### Prioridade 2: Melhorias Estruturais de Alto Impacto
- Refatorações que melhoram a estabilidade geral do sistema
- Consolidação de sistemas duplicados
- Melhorias de arquitetura fundamentais

### Prioridade 3: Melhorias de Experiência do Usuário
- Aprimoramentos na UI/UX
- Ajustes de feedback visual e sonoro
- Melhorias incrementais de jogabilidade

### Prioridade 4: Refatorações de Código e Otimizações
- Limpeza de código e redução de redundância
- Otimizações de desempenho
- Melhoria na documentação interna

## Plano de Implementação

### Fase 1: Correção de Bugs Críticos (Estimativa: 1-2 semanas)

1. **Centralização do Gerenciamento de Diálogos**
   - **Problema**: Duplicação entre `prologue.gd` e `prologue_dialogue_manager.gd`
   - **Solução**: Consolidar em um único sistema gerenciador de diálogo
   - **Tarefas**:
     - Criar uma nova classe `DialogueManager` que combine a funcionalidade de ambos scripts
     - Migrar funcionalidades específicas para a nova classe
     - Atualizar referências no prólogo para usar a nova classe
     - Remover códigos redundantes

2. **Correção do Processamento de Textos de Contexto**
   - **Problema**: Textos marcados com asteriscos às vezes são mostrados incorretamente
   - **Solução**: Refatorar a função `is_description_text()` 
   - **Tarefas**:
     - Implementar algoritmo robusto para detecção de textos de contexto
     - Adicionar testes automatizados para validar a detecção
     - Garantir tratamento consistente em todas as caixas de diálogo

3. **Gerenciamento Consistente do Joystick Virtual**
   - **Problema**: O joystick virtual pode não ser corretamente escondido/mostrado
   - **Solução**: Centralizar gerenciamento no script do jogador
   - **Tarefas**:
     - Refatorar `player.gd` para encapsular toda a lógica de controle
     - Implementar métodos públicos para mostrar/esconder o joystick
     - Remover manipulações diretas do joystick em outros scripts

### Fase 2: Consolidação do Sistema de Gerenciamento de Cenas (Estimativa: 2-3 semanas)

1. **Unificação de Game.gd e Orquestrador.gd**
   - **Problema**: Sistema híbrido com estados gerenciados por ambos scripts
   - **Solução**: Migrar completamente para o sistema em Game.gd
   - **Tarefas**:
     - Transferir todas as funcionalidades do Orquestrador.gd para Game.gd
     - Criar uma camada de compatibilidade temporária
     - Atualizar todas as referências para usar apenas Game.gd
     - Deprecar e eventualmente remover Orquestrador.gd

2. **Implementação de Sistema de Transição Unificado**
   - **Problema**: Múltiplos métodos para realizar transições (fade, loading, instant)
   - **Solução**: Sistema de transição unificado com interface clara
   - **Tarefas**:
     - Criar enum para tipos de transição
     - Implementar um único método que aceita tipo como parâmetro
     - Atualizar todas as chamadas de transição para usar o novo sistema

3. **Redução de Acoplamento com Game.gd**
   - **Problema**: Referências diretas a `/root/Game` em múltiplos scripts
   - **Solução**: Implementar sistema baseado em sinais
   - **Tarefas**:
     - Definir conjunto de sinais para comunicação entre cenas e Game.gd
     - Refatorar scripts para emitir sinais em vez de chamar métodos diretos
     - Implementar conexão de sinais no Game.gd

### Fase 3: Sistema de Diálogo Reutilizável (Estimativa: 3-4 semanas)

1. **Criação de Sistema de Diálogo Baseado em Recursos**
   - **Problema**: Falta de abstração adequada no sistema de diálogos
   - **Solução**: Criar sistema baseado em recursos para definição de diálogos
   - **Tarefas**:
     - Definir formato de dados para diálogos (JSON/Dictionary)
     - Criar classe Resource para representar árvores de diálogo
     - Implementar parser e interpretador para o formato de dados
     - Criar editor visual para diálogos (opcional)

2. **Separação de Apresentação e Dados**
   - **Problema**: Lógica de apresentação e dados misturados
   - **Solução**: Implementar arquitetura MVC para sistema de diálogo
   - **Tarefas**:
     - Criar componentes separados para modelo, visualização e controle
     - Refatorar caixas de diálogo para consumir dados do modelo
     - Implementar controlador para gerenciar fluxo de diálogo

3. **Classe Base para Componentes de Diálogo**
   - **Problema**: Duplicação entre tipos de caixas de diálogo
   - **Solução**: Criar classe base abstrata
   - **Tarefas**:
     - Extrair funcionalidade comum para classe base
     - Refatorar caixas existentes para herdar da classe base
     - Implementar método para seleção automática do tipo correto de caixa

### Fase 4: Melhorias de Código e Optimizações (Estimativa: Contínuo)

1. **Implementação de Padrões de Código**
   - **Problema**: Inconsistência na nomenclatura e estrutura
   - **Solução**: Adotar padrões definidos no guia de código
   - **Tarefas**:
     - Revisar e atualizar nomes de variáveis e funções
     - Reorganizar estrutura de scripts
     - Adicionar documentação de código

2. **Funções Utilitárias para Verificação de Nós**
   - **Problema**: Verificações repetitivas de `is_instance_valid()`
   - **Solução**: Criar biblioteca de funções utilitárias
   - **Tarefas**:
     - Implementar funções helper para verificações comuns
     - Substituir verificações repetitivas por chamadas à biblioteca

3. **Sistema de Log Estruturado**
   - **Problema**: Uso inconsistente de print e printerr
   - **Solução**: Implementar sistema de log configurável
   - **Tarefas**:
     - Criar classe Logger com níveis de severidade
     - Substituir chamadas de debug por Logger
     - Implementar filtro de logs por categoria/módulo

## Cronograma Tentativo

```
Semanas:   1   2   3   4   5   6   7   8   9   10
Fase 1:    ███████
Fase 2:        ████████████
Fase 3:                ████████████████
Fase 4:    ████████████████████████████████████
```

## Métricas de Sucesso

- **Redução de Bugs**: Diminuição no número de bugs reportados
- **Tempo de Desenvolvimento**: Redução no tempo necessário para implementar novos recursos
- **Cobertura de Testes**: Aumento na porcentagem de código coberto por testes
- **Complexidade Ciclomática**: Redução da complexidade média por função
- **Feedback do Usuário**: Melhoria nas avaliações de jogabilidade e estabilidade

## Considerações de Implementação

1. **Compatibilidade**: Garantir que as mudanças sejam compatíveis com o código existente
2. **Testes**: Implementar testes para validar as alterações antes da integração
3. **Documentação**: Atualizar documentação para refletir novas arquiteturas e sistemas
4. **Revisão de Código**: Estabelecer processo de revisão para todas as alterações

---

*Este plano deve ser revisado e ajustado conforme a implementação avança e novos insights são obtidos.*

*Documento criado em: 08/06/2025*

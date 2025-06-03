# Fluxo de Jogo e Balanceamento - Documentação

## Visão Geral do Fluxo de Jogo

O Projeto Code apresenta um fluxo de jogo estruturado com foco na experiência narrativa e na progressão do jogador. Este documento detalha o fluxo principal do jogo, os sistemas de balanceamento e considerações de game design.

## Estrutura de Progressão

### Início e Introdução

1. **Menu Principal**
   - Ponto de entrada do jogador
   - Opções: Novo Jogo, Continuar, Configurações, Sair

2. **Prólogo**
   - Introdução narrativa para contextualização
   - Diálogos introdutórios apresentando o mundo e premissa
   - Sistema para pular em jogadas subsequentes

3. **Tutorial Integrado**
   - Instruções básicas de movimento e interação
   - Introdução gradual aos mecânicos principais
   - Feedback visual para guiar o jogador

### Fluxo Principal

O fluxo principal de jogo consiste em:

```
Menu Principal → Prólogo → Gameplay → Conclusão → Menu Principal
                     ↑          ↓
                     └── Pausa ←┘
```

Durante o gameplay, o jogador pode:
- Pausar o jogo a qualquer momento
- Acessar configurações através do menu de pausa
- Salvar o progresso (recurso planejado)
- Retornar ao menu principal

## Sistemas de Gameplay

### Interações e Diálogos

O sistema de diálogos é central para a experiência de jogo, permitindo:
- Conversas com NPCs
- Obtenção de informações e pistas
- Desenvolvimento da narrativa
- Escolhas que afetam o desenrolar da história (recurso planejado)

### Exploração

A exploração de ambientes é facilitada por:
- Controles responsivos em desktop e dispositivos móveis
- Sistema de câmera que segue o jogador suavemente
- Pontos de interesse destacados visualmente

### Objetivos e Missões

O sistema de missões é estruturado em:
- **Objetivos Principais**: Avançam a narrativa central
- **Objetivos Secundários**: Opcionais, oferecem contexto adicional
- **Desafios**: Pequenos puzzles ou tarefas específicas

## Balanceamento

### Curva de Dificuldade

O jogo implementa uma curva de dificuldade progressiva:

1. **Fase Inicial** (Primeiros 10-15 minutos)
   - Foco em familiarização com controles
   - Desafios simples de navegação
   - Diálogos introdutórios com escolhas óbvias

2. **Fase Intermediária** (15-45 minutos)
   - Introdução de mecânicas mais complexas
   - Diálogos com escolhas que têm consequências sutis
   - Puzzles que requerem atenção a detalhes

3. **Fase Avançada** (45+ minutos)
   - Integração de todas as mecânicas
   - Escolhas com impacto significativo
   - Resolução de conflitos narrativos

### Parâmetros de Balanceamento

Os seguintes parâmetros são importantes para o balanceamento:

#### Movimento do Jogador
```gdscript
# Velocidade base do jogador em pixels por segundo
var speed = 200

# Esta velocidade foi determinada considerando:
# - Tamanho médio das salas: ~1000x800 pixels
# - Tempo desejado para atravessar uma sala: ~5 segundos
# - Escala dos sprites: 1 pixel = ~0.1 metro no mundo do jogo
```

#### Tempo de Resposta
```gdscript
# Tempo para mostrar cada caractere em diálogos (segundos)
var dialogue_char_speed = 0.03  # Ajustável nas configurações

# Tempo de fade para transições entre cenas
var fade_duration = 0.5  # Rápido o suficiente para não frustrar, lento o suficiente para ser perceptível
```

## Feedback ao Jogador

### Visual
- Destaque de elementos interativos
- Animações de feedback para ações
- Efeitos visuais para transições e eventos importantes

### Auditivo
- Sons de interface para confirmação de ações
- Música para estabelecer atmosfera
- Efeitos sonoros para eventos e interações

### Tátil (Dispositivos Móveis)
- Vibração para eventos significativos (recurso planejado)
- Feedback tátil no joystick virtual

## Considerações de Design

### Princípios Fundamentais

1. **Clareza**: O jogador deve sempre entender o que está acontecendo e o que precisa fazer
2. **Progressão**: Desafios graduais que acompanham a curva de aprendizado
3. **Propósito**: Cada elemento deve ter um propósito claro no gameplay ou narrativa
4. **Consistência**: Mecânicas e controles consistentes em toda a experiência

### Público-Alvo

O jogo é projetado considerando:
- Faixa etária principal: 12+
- Jogadores casuais e experientes
- Interesse em narrativas interativas
- Compatibilidade com PC e dispositivos móveis

### Playtesting e Iteração

O processo de desenvolvimento inclui ciclos regulares de:
1. Implementação de funcionalidades
2. Testes internos
3. Ajustes baseados no feedback
4. Repetição do processo

## Métricas de Engajamento

Para avaliar o sucesso do balanceamento, consideramos:
- Tempo médio de sessão
- Taxa de conclusão de objetivos
- Pontos de abandono
- Feedback direto dos jogadores

## Planos de Expansão Futura

### Recursos Planejados
- Sistema de escolhas com impacto significativo na narrativa
- Múltiplos finais baseados nas decisões do jogador
- Sistema de inventário e colecionáveis
- Expansão da história com novos capítulos

### Ajustes de Balanceamento
- Refinamento da curva de dificuldade baseado no feedback
- Expansão das opções de acessibilidade
- Melhorias na responsividade dos controles
- Otimização para diferentes dispositivos

## Diretrizes para Modificações

Ao modificar ou expandir o fluxo de jogo:

1. **Mantenha a Coesão Narrativa**:
   - Novas seções devem se integrar naturalmente à história existente
   - Preserve o tom e estilo estabelecidos

2. **Teste Extensivamente**:
   - Verifique o balanceamento em diferentes cenários
   - Teste com jogadores de diferentes níveis de experiência

3. **Documente as Mudanças**:
   - Atualize este documento com novos parâmetros
   - Explique a razão por trás de alterações significativas

4. **Preserve a Experiência Core**:
   - Mantenha os princípios fundamentais de design
   - Evite alterações drásticas sem playtesting adequado

## Conclusão

O fluxo de jogo e balanceamento do Projeto Code são elementos fundamentais para a experiência do jogador. Seguindo as diretrizes e considerações apresentadas neste documento, podemos garantir uma experiência coesa, envolvente e satisfatória, enquanto mantemos espaço para expandir e refinar o jogo no futuro.

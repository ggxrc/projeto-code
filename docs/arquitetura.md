# Análise de Arquitetura do Projeto

Este documento apresenta uma análise técnica da arquitetura atual do projeto, identificando componentes principais, relacionamentos entre eles, e oportunidades para melhorias estruturais.

## Componentes Principais

### 1. Sistema de Gerenciamento de Cenas

O projeto utiliza um sistema híbrido para gerenciar cenas, dividido entre:

- **Game.gd**: Sistema principal, gerencia estados do jogo e transições entre as cenas
- **Orquestrador.gd**: Sistema de compatibilidade para código legado, oferece uma interface alternativa

```
┌─────────────────┐
│     Game.gd     │
│ (Estados, cenas)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│Orquestrador.gd  │◄────┤  Cenas do jogo  │
│(Compatibilidade)│     │(Menu, Prologue) │
└─────────────────┘     └─────────────────┘
```

#### Problemas Identificados:
- Redundância entre os dois sistemas
- Falta de definição clara sobre qual sistema deve ser usado em novos componentes
- Difícil rastreamento do fluxo de controle entre cenas

#### Oportunidades:
- Unificar o sistema em um único controlador
- Implementar um sistema baseado em sinais para reduzir acoplamento
- Documentar claramente a interface de gerenciamento de cenas

### 2. Sistema de Diálogos

O sistema de diálogos está distribuído em vários componentes:

- **dialogue_box.gd**: Exibe diálogos simples
- **choice_dialogue_box.gd**: Exibe diálogos com opções de escolha
- **description_box.gd**: Exibe textos de descrição/contexto
- **prologue.gd**: Implementa a lógica específica de diálogo do prólogo
- **prologue_dialogue_manager.gd**: Contém lógica duplicada do prólogo

```
┌───────────────────┐    ┌────────────────────┐
│   dialogue_box    │    │ choice_dialogue_box│
└────────┬──────────┘    └──────────┬─────────┘
         │                          │
         │                          │
         ▼                          ▼
┌─────────────────────────────────────────────┐
│               prologue.gd                   │
│    (Implementação específica de diálogo)    │
└─────────────────────────────────────────────┘
                     │
                     │ (Duplicação)
                     ▼
┌─────────────────────────────────────────────┐
│         prologue_dialogue_manager.gd        │
└─────────────────────────────────────────────┘
```

#### Problemas Identificados:
- Falta de abstração adequada
- Duplicação de código entre prologue.gd e prologue_dialogue_manager.gd
- Uso excessivo de índices hardcoded para identificar opções
- Forte acoplamento entre a lógica de diálogo e a cena específica

#### Oportunidades:
- Criar um sistema de diálogo reutilizável baseado em recursos
- Separar dados de diálogo da lógica de apresentação
- Usar um formato padronizado (JSON/Dictionary) para definir árvores de diálogo

### 3. Sistema de Input e Controle

O jogo implementa controles para teclado/mouse e dispositivos móveis:

- **player.gd**: Implementa o controle do jogador
- **touch_screen_joystick.gd**: Implementa o joystick virtual para dispositivos móveis

```
┌───────────────────┐
│     player.gd     │
│  (Movimentação)   │
└────────┬──────────┘
         │
         │ (Referência)
         ▼
┌───────────────────┐
│touch_screen_joystick│
│  (Input tátil)    │
└───────────────────┘
```

#### Problemas Identificados:
- Gerenciamento inconsistente do joystick virtual
- Responsabilidades misturadas entre scripts
- Dependências diretas em vez de sinais

#### Oportunidades:
- Centralizar gerenciamento de input em um sistema dedicado
- Usar padrão Observer para comunicação entre componentes
- Implementar um sistema de configuração de controles

## Recomendações para Refatoração

### Fase 1: Consolidação do Sistema de Cenas
1. Decidir entre `Game.gd` e `Orquestrador.gd` como controlador principal
2. Refatorar o sistema escolhido para usar sinais em vez de referências diretas
3. Depreciar gradualmente o sistema não escolhido

### Fase 2: Refatoração do Sistema de Diálogo
1. Criar uma classe base `DialogueSystem` com funcionalidade compartilhada
2. Implementar um formato de dados para definição de diálogos
3. Separar a lógica de apresentação da lógica de dados
4. Consolidar `prologue.gd` e `prologue_dialogue_manager.gd`

### Fase 3: Melhoria do Sistema de Input
1. Centralizar o gerenciamento de input/controles
2. Implementar abstração para diferentes tipos de dispositivos
3. Adicionar sistema de configuração de controles

## Padrões de Design Sugeridos

1. **Singleton**: Para gerenciar o estado global do jogo (já parcialmente implementado)
2. **Observer/Signal**: Para comunicação entre componentes desacoplados
3. **State**: Para gerenciar os diferentes estados do jogo
4. **Strategy**: Para diferentes implementações de controle (teclado vs. touch)
5. **Factory**: Para criar e gerenciar os diferentes tipos de diálogos

## Métricas de Código

- **Acoplamento**: Alto - Muitas referências diretas entre componentes
- **Coesão**: Média - Algumas classes têm múltiplas responsabilidades
- **Duplicação**: Alta - Vários blocos de código duplicados (especialmente no sistema de diálogo)
- **Testabilidade**: Baixa - Difícil isolar componentes para testes unitários

## Conclusão

A arquitetura atual do projeto apresenta desafios típicos de um projeto que cresceu organicamente. Com refatorações focadas e graduais, seguindo os princípios SOLID e outros padrões de design, é possível transformar a base de código em um sistema mais modular, testável e manutenível sem interromper o desenvolvimento de novos recursos.

A prioridade deve ser dada à consolidação do sistema de gerenciamento de cenas, seguido pelo sistema de diálogo, pois estes são componentes fundamentais que afetam todas as outras partes do jogo.

*Documento criado em: 08/06/2025*

# Registro de Bugs e Problemas

Este documento serve como um registro centralizado de todos os bugs, redundâncias e problemas identificados no projeto. Utilize este documento como referência para correções e melhorias futuras.

## Instruções de Uso

1. Ao encontrar um novo bug ou problema, adicione-o a este documento com detalhes suficientes para reproduzi-lo
2. Ao resolver um bug, não o remova do documento - apenas marque-o como resolvido com data e descrição da solução
3. Categorize os problemas por tipo e gravidade para facilitar a priorização

## Bugs Ativos

### Sistema de Diálogo

1. **Bug de Escolhas Duplicadas no Prólogo** [CORRIGIDO: 07/06/2025]
   - **Descrição**: Ao escolher opções incorretas durante o diálogo do prólogo, as opções não são corretamente removidas da lista de escolhas disponíveis
   - **Arquivo**: `scenes/prologue/prologue.gd`
   - **Solução**: Foi implementada uma verificação baseada em texto em vez de índices para garantir que as opções incorretas sejam corretamente identificadas e removidas

2. **Mensagens de Resposta Idênticas** [CORRIGIDO: 07/06/2025]
   - **Descrição**: Diferentes escolhas podem receber a mesma resposta de texto, causando confusão para o jogador
   - **Arquivo**: `scenes/prologue/prologue.gd`
   - **Solução**: Mensagens de resposta personalizadas foram criadas para cada escolha

3. **Processamento Incorreto de Textos de Contexto**
   - **Descrição**: Textos marcados como contexto (com asteriscos) às vezes são mostrados ao jogador
   - **Arquivo**: `scenes/prologue/prologue.gd`
   - **Impacto**: Baixo - Afeta apenas a experiência visual
   - **Sugestão**: Revisar a função `is_description_text()` e garantir consistência nos textos de contexto

4. **Gerenciamento Inconsistente do Joystick Virtual**
   - **Descrição**: O joystick virtual pode não ser corretamente escondido/mostrado durante transições entre cenas
   - **Arquivos**: `scenes/actors/player.gd`, `scenes/prologue/prologue.gd`
   - **Impacto**: Médio - Afeta a experiência em dispositivos móveis
   - **Sugestão**: Centralizar o gerenciamento do joystick no script do jogador

5. **Duplicação de Lógica de Diálogos Entre Scripts**
   - **Descrição**: Existe código redundante e duplicação de lógica entre `prologue.gd` e `prologue_dialogue_manager.gd`
   - **Arquivos**: `scenes/prologue/prologue.gd`, `scenes/prologue/prologue_dialogue_manager.gd`
   - **Impacto**: Alto - Causa confusão na manutenção e pode levar a bugs
   - **Sugestão**: Unificar o gerenciamento de diálogo em um único script ou criar uma hierarquia clara

### Transições e Loading

1. **Comportamento Inconsistente da Tela de Loading**
   - **Descrição**: Em algumas situações, a tela de loading não é mostrada ou persiste por tempo excessivo
   - **Arquivo**: `scenes/global/effects/loading_screen.gd`
   - **Impacto**: Médio - Afeta experiência do usuário durante transições
   - **Sugestão**: Implementar um sistema de timeout e logging mais detalhado

### Interface do Usuário

1. **Falta de Feedback Visual para Botões**
   - **Descrição**: Alguns botões não fornecem feedback visual adequado quando pressionados
   - **Arquivos**: Vários arquivos de UI
   - **Impacto**: Baixo - Afeta apenas a experiência do usuário
   - **Sugestão**: Implementar animações e efeitos sonoros consistentes para todos os botões

## Problemas de Implementação

### Sistema de Diálogo

1. **Uso excessivo de índices hardcoded**
   - **Descrição**: O código do diálogo usa índices numéricos fixos (0, 1, 2) para identificar opções, o que dificulta manutenção e torna o código mais propenso a erros
   - **Arquivo**: `scenes/prologue/prologue.gd`
   - **Sugestão**: Usar constantes nomeadas ou enums para identificar opções ou usar comparação baseada em texto

2. **Falta de abstração no sistema de diálogos**
   - **Descrição**: A lógica de diálogo está fortemente acoplada com a cena específica, dificultando reuso em outras partes do jogo
   - **Arquivos**: `scenes/prologue/prologue.gd`, `scenes/diálogos/dialogue_box.gd`, `scenes/diálogos/choice_dialogue_box.gd`
   - **Sugestão**: Criar um sistema de diálogo reutilizável que possa ser inicializado com dados de um formato comum (JSON/Dictionary)

3. **Duplicação de lógica entre scripts de diálogo**
   - **Descrição**: Existe código duplicado entre `prologue.gd` e `prologue_dialogue_manager.gd`
   - **Sugestão**: Consolidar a lógica em um único gerenciador ou usar herança adequada

4. **Muitas variáveis de estado global**
   - **Descrição**: O sistema de diálogo usa muitas variáveis globais para rastrear estado
   - **Arquivo**: `scenes/prologue/prologue.gd`
   - **Sugestão**: Usar classes de estado ou recursos Godot para encapsular o estado

### Gerenciamento de Estado

1. **Acoplamento forte entre Game.gd e cenas**
   - **Descrição**: A referência direta a um singleton global (/root/Game) cria acoplamento forte e dificulta testes
   - **Arquivos**: Múltiplos scripts, incluindo `scenes/prologue/prologue.gd`
   - **Sugestão**: Usar injeção de dependência ou sinais para reduzir acoplamento

2. **Inconsistência no gerenciamento de estados do jogo**
   - **Descrição**: Existe um sistema híbrido com estados gerenciados pelo Game.gd e pelo Orquestrador.gd
   - **Arquivos**: `scenes/orquestrador/game.gd` e `scenes/orquestrador/Orquestrador.gd`
   - **Sugestão**: Migrar completamente para um único sistema ou criar uma interface clara entre os dois

3. **Uso inconsistente de process_mode**
   - **Descrição**: A manipulação de process_mode é feita de maneira inconsistente ao pausar/retomar o jogo
   - **Arquivo**: `scenes/orquestrador/game.gd`
   - **Sugestão**: Padronizar o uso de process_mode e documentar a abordagem

4. **Falha de Comunicação entre Menu Principal e Game.gd**
   - **Descrição**: O script `menu_principal.gd` utiliza uma busca complexa pelo orquestrador em vez de acessar diretamente
   - **Arquivos**: `scenes/main menu/menu_principal.gd`
   - **Impacto**: Médio - Pode levar a falhas de navegação caso a estrutura de cena seja alterada
   - **Sugestão**: Utilizar sinais ou exportar uma referência direta para o controlador de cenas

5. **Tratamento inconsistente de transições de cena**
   - **Descrição**: Existem múltiplos métodos para realizar transições (fade, loading, instant) sem uma estratégia clara
   - **Arquivos**: `scenes/orquestrador/game.gd`
   - **Impacto**: Médio - Dificulta manutenção e pode causar problemas visuais durante transições
   - **Sugestão**: Implementar um sistema de transição unificado com uma interface clara

### Código Redundante

1. **Funções similares para tipos diferentes de diálogo**
   - **Descrição**: `dialogue_box`, `choice_dialogue_box` e `description_box` têm implementações similares para exibir texto
   - **Sugestão**: Criar uma classe base comum e estender para os casos específicos

2. **Duplicação de código para verificação de nós**
   - **Descrição**: Verificações de `is_instance_valid()` são repetidas em várias partes do código
   - **Sugestão**: Criar funções utilitárias para verificação de nós

3. **Inicialização redundante no _ready()**
   - **Descrição**: Muitos scripts têm padrões de inicialização similares que poderiam ser abstraídos
   - **Arquivos**: Múltiplos scripts
   - **Sugestão**: Criar classes base com métodos de inicialização comuns

4. **Métodos duplicados para interface com o jogador**
   - **Descrição**: As funções de manipulação de joystick virtual estão espalhadas entre `player.gd` e outras classes
   - **Arquivos**: `scenes/actors/player.gd`, `scenes/prologue/prologue.gd`
   - **Impacto**: Médio - Dificulta modificações e manutenção do sistema de controle
   - **Sugestão**: Centralizar o gerenciamento de controles no script do jogador

5. **Busca redundante por nós de interface**
   - **Descrição**: Vários scripts fazem busca manual por nós de UI usando `get_node_or_null()` repetidamente
   - **Arquivos**: `scenes/orquestrador/game.gd`, `scenes/main menu/menu_principal.gd`
   - **Impacto**: Baixo - Afeta apenas a legibilidade e manutenção do código
   - **Sugestão**: Criar um sistema de referências automáticas para elementos de UI

### Problemas de Física e Colisão

1. **Múltiplos sistemas de colisão para o sofá**
   - **Descrição**: Existem dois scripts diferentes tentando gerenciar a colisão do sofá
   - **Arquivos**: `scenes/prologue/couch_collision.gd` e `scenes/prologue/prologue.gd` (função `setup_couch_collision()`)
   - **Sugestão**: Consolidar a lógica em um único sistema

## Possíveis Melhorias

1. **Refatoração do Sistema de Diálogo**
   - Criar um formato de dados (como JSON) para definir árvores de diálogo
   - Implementar um sistema de diálogo baseado em recursos para facilitar edição e localização
   - Separar lógica de apresentação da lógica de dados
   - **ESPECÍFICO**: Consolidar a lógica de `prologue.gd` e `prologue_dialogue_manager.gd` em um único sistema

2. **Melhoria na Gestão de Estado do Jogo**
   - Implementar um sistema de estados mais robusto usando padrões como máquina de estados
   - Reduzir dependências globais usando técnicas como injeção de dependência
   - Consolidar o sistema de transições entre cenas em uma única abordagem
   - **ESPECÍFICO**: Eliminar a dependência entre `Orquestrador.gd` e `game.gd`, migrar para um único sistema

3. **Otimização de Performance**
   - Revisão no uso de chamadas deferred que podem estar causando overhead desnecessário
   - Melhor gerenciamento de recursos visuais e tweens para garantir que sejam devidamente desalocados
   - Implementar pooling de objetos para elementos frequentemente criados/destruídos
   - **ESPECÍFICO**: Otimizar o carregamento e uso da tela de loading para garantir transições suaves

4. **Melhoria na Detecção de Erros**
   - Adicionar mais verificações para garantir que nós e recursos existam antes de tentar usá-los
   - Implementar logs estruturados para facilitar depuração
   - Adicionar sistema de log que possa ser habilitado/desabilitado por módulo
   - **ESPECÍFICO**: Adicionar tratamento de erros mais robusto nas transições entre cenas

5. **Melhorias na Interface do Usuário**
   - Implementar sistema de temas consistentes para toda a UI
   - Melhorar acessibilidade com opções de tamanho de fonte e contraste
   - Usar containers para layouts mais responsivos

6. **Sistema de Controle Aprimorado**
   - Implementar suporte completo a gamepad
   - Configuração de controles pelo usuário
   - Sistema adaptativo que detecta e alterna entre diferentes métodos de input

7. **Gerenciamento de Recursos**
   - Implementar carregamento de recursos sob demanda
   - Unload de recursos não utilizados para economizar memória
   - Sistema de caching para recursos frequentemente utilizados

8. **Melhorias de Arquitetura**
   - Migrar para um sistema baseado em componentes mais modular
   - Implementar gerenciador de dependências para singletons
   - Usar padrões de projeto como Observer, Command e Strategy onde apropriado

---

*Última atualização: 08/06/2025*

## Análise Atual da Arquitetura

A análise atual do código revela um sistema que evoluiu de forma orgânica, mas que agora apresenta alguns desafios arquiteturais. Os principais problemas identificados são:

1. **Sistema de Gerenciamento de Cenas Híbrido**: O projeto utiliza simultaneamente `Game.gd` e `Orquestrador.gd` para gerenciar cenas, o que cria redundância e possíveis conflitos.

2. **Forte Acoplamento**: As cenas se referenciam diretamente, usando paths absolutos como `/root/Game`, criando forte acoplamento.

3. **Duplicação de Lógica**: Existe código duplicado em vários lugares, especialmente no sistema de diálogo.

4. **Verificações Defensivas Repetitivas**: O código constantemente verifica se nós existem com `is_instance_valid()` ou `get_node_or_null()`, o que poderia ser encapsulado.

5. **Mistura de Responsabilidades**: Alguns scripts, como `prologue.gd`, gerenciam tanto a lógica de apresentação quanto a de dados.

A recomendação principal é consolidar progressivamente o código, começando pelos sistemas mais fundamentais como o gerenciamento de cenas e diálogo, antes de prosseguir com outras melhorias.

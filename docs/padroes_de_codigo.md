# Guia de Padrões de Código

Este documento estabelece padrões e práticas recomendadas para o desenvolvimento do Projeto Code, visando melhorar a consistência, legibilidade e manutenção do código.

## Convenções de Nomenclatura

### Arquivos e Pastas

- **Nomes de Arquivos**: Usar `snake_case` para nomes de arquivos (ex: `player_controller.gd`, `main_menu.tscn`)
- **Nomes de Cenas**: Usar `PascalCase` para nomes de nodes principais dentro das cenas (ex: `PlayerCharacter`, `MainMenu`)
- **Organização de Pastas**:
  - `scenes/`: Cenas principais do jogo
  - `scripts/`: Scripts reutilizáveis não ligados diretamente a cenas
  - `assets/`: Recursos como imagens, sons, etc.
  - `docs/`: Documentação do projeto

### Código GDScript

- **Variáveis**: Usar `snake_case` (ex: `player_health`, `movement_speed`)
- **Constantes**: Usar `SCREAMING_SNAKE_CASE` (ex: `MAX_HEALTH`, `DEFAULT_SPEED`)
- **Funções**: Usar `snake_case` (ex: `process_input()`, `calculate_damage()`)
- **Classes**: Usar `PascalCase` (ex: `PlayerController`, `DialogueManager`)
- **Sinais**: Usar `snake_case` no infinitivo (ex: `health_changed`, `level_completed`)

## Estrutura do Código

### Organização de Scripts

Organizar funções dentro dos scripts na seguinte ordem:

1. Declarações de Classes (se houver)
2. Constantes
3. Exportáveis / Propriedades
4. Variáveis
5. Funções Built-in (`_ready`, `_process`, etc.)
6. Funções de Signal
7. Funções Públicas
8. Funções Privadas (prefixo `_`)

```gdscript
extends Node

# Constantes
const MAX_SPEED = 300

# Exportáveis
@export var health: int = 100

# Variáveis
var velocity = Vector2.ZERO
var current_weapon = null

# Funções Built-in
func _ready():
    initialize_player()

func _process(delta):
    process_movement(delta)

# Handlers de Signal
func _on_area_entered(area):
    process_collision(area)

# Funções Públicas
func take_damage(amount):
    health -= amount

# Funções Privadas
func _initialize_player():
    # Implementação
```

### Comentários e Documentação

- **Documentação de Funções**: Documentar funções públicas importantes com comentários explicando seu propósito
- **Comentários TODO**: Usar formato padronizado: `# TODO: Descrição da tarefa pendente`
- **Comentários de Seção**: Usar comentários para dividir seções de código grandes

```gdscript
# Processa o movimento do jogador com base na entrada do usuário
# Parâmetros:
# - delta: Tempo desde o último frame
# Retorna: void
func process_movement(delta):
    # Implementação

# TODO: Refatorar esta função para usar o novo sistema de física
func calculate_jump_height():
    # Implementação

# ====== SISTEMA DE INVENTÁRIO ======
func add_item(item):
    # Implementação
```

## Práticas de Codificação

### Gerenciamento de Estado

- Usar enums para estados ao invés de strings ou números mágicos
- Implementar máquinas de estado para comportamentos complexos

```gdscript
enum PlayerState {
    IDLE,
    RUNNING,
    JUMPING,
    FALLING,
    ATTACKING
}

var current_state = PlayerState.IDLE

func change_state(new_state):
    current_state = new_state
    match current_state:
        PlayerState.IDLE:
            play_animation("idle")
        PlayerState.RUNNING:
            play_animation("run")
        # etc.
```

### Comunicação entre Nós

- **Preferir Sinais**: Usar sinais para comunicação entre nós não diretamente relacionados
- **Injeção de Dependência**: Passar referências a outros nós via parâmetros quando possível
- **Evitar Referências Globais**: Minimizar o uso de padrões singleton e paths absolutos

```gdscript
# Recomendado
signal player_died

func take_damage(amount):
    health -= amount
    if health <= 0:
        player_died.emit()

# Em vez de:
func take_damage(amount):
    health -= amount
    if health <= 0:
        get_node("/root/GameManager").player_died()
```

### Verificações de Segurança

- **Verificar Nulos**: Sempre verificar se nós e recursos existem antes de usá-los
- **Mensagens de Erro**: Usar `push_error()` ou `printerr()` para log de erros críticos
- **Fallbacks**: Fornecer valores padrão quando possível

```gdscript
func attack_target(target):
    if not is_instance_valid(target):
        push_error("Tentando atacar um alvo inválido")
        return
        
    # Continuar com lógica de ataque
```

## Desempenho e Otimização

- **Minimizar _process**: Evitar operações pesadas em funções que rodam a cada frame
- **Usar Timers**: Preferir `Timer` para operações recorrentes em vez de contar frames
- **Pooling de Objetos**: Para objetos frequentemente criados e destruídos
- **Limitação de Visibilidade**: Usar CanvasItem.visible ou RadioGroup.process_mode para desativar processamento desnecessário

```gdscript
# Em vez de
var timer = 0.0

func _process(delta):
    timer += delta
    if timer >= 5.0:
        timer = 0.0
        check_for_enemies()

# Prefira
func _ready():
    var timer = Timer.new()
    timer.wait_time = 5.0
    timer.autostart = true
    timer.timeout.connect(check_for_enemies)
    add_child(timer)
```

## Testes e Depuração

- **Modo Debug**: Usar flags para alternar saídas de depuração
- **Asserts**: Usar afirmações para verificar suposições críticas
- **Entradas de Teste**: Criar teclas de atalho para testar funcionalidades

```gdscript
const DEBUG = true

func complex_calculation(value):
    if DEBUG:
        print("Calculando com valor: ", value)
    
    assert(value > 0, "O valor deve ser positivo")
    
    # Implementação
```

## Versionamento e Colaboração

- **Mensagens de Commit**: Usar mensagens claras e descritivas
- **Branches**: Criar branches para novas funcionalidades e correções
- **Pull Requests**: Revisar código antes de mesclar em branches principais
- **Tarefas pendentes**: Documentar TODOs em um sistema de issue tracking, não apenas em comentários

## Considerações Finais

Estes padrões e práticas são diretrizes, não regras rígidas. O objetivo é melhorar a consistência e qualidade do código. Em caso de dúvida, priorize a legibilidade e manutenibilidade do código.

Padrões e práticas devem evoluir com o projeto. Este documento deve ser revisado e atualizado periodicamente conforme o projeto avança.

*Documento criado em: 08/06/2025*

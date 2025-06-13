# Sistema de Controle do Jogador - Documentação

## Visão Geral
O Projeto Code implementa um sistema de controle de personagem flexível que funciona tanto em dispositivos de desktop (usando teclado) quanto em dispositivos móveis (usando controles de toque). O sistema é projetado para ser responsivo e adaptável a diferentes plataformas.

## Componentes Principais

### Player Controller Básico
Localização: `scenes/actors/player.gd` e `scripts/basic_player.gd`

Este componente implementa a lógica básica de movimentação do personagem:
- Detecção de entrada de teclado
- Cálculo de velocidade e direção
- Movimentação física do personagem

#### Código Principal:
```gdscript
func _physics_process(delta: float) -> void:
    var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
    if dir:
        velocity = dir * 200
    else:
        velocity.x = move_toward(velocity.x, 0,200)
        velocity.y = move_toward(velocity.y, 0,200)
    
    move_and_slide()
```

### Joystick Virtual para Tela de Toque
Localização: `scripts/touch_screen_joystick.gd`

Um sistema avançado de joystick virtual para dispositivos com tela sensível ao toque:
- Completamente personalizável visualmente
- Suporte para modos fixo e dinâmico
- Configuração de sensibilidade e zona morta
- Sistema responsivo que se adapta a diferentes tamanhos de tela

#### Características principais:
- **Uso de Texturas**: Possibilidade de usar texturas personalizadas ou desenhos gerados
- **Modo Fixo/Dinâmico**: O joystick pode ficar fixo na tela ou aparecer onde o jogador tocar
- **Personalização Visual**: Controle sobre cores, tamanhos e opacidade
- **Responsividade**: Adapta-se automaticamente à resolução e orientação do dispositivo

## Estrutura da Cena do Jogador

A cena do jogador (`player.tscn`) é construída com os seguintes componentes:
- `CharacterBody2D`: Nó principal para controle físico do personagem
- `CollisionShape2D`: Define a forma de colisão do personagem
- `Sprite2D`: Renderiza o visual do personagem
- `AnimationPlayer`: Controla animações do personagem

## Como Usar o Sistema de Controle

### Controles de Teclado

Os controles padrão de teclado usam:
- Setas direcionais para movimento
- Tecla Esc para pausar o jogo

Para personalizar os controles de teclado:
1. Edite o mapeamento de entrada nas configurações do projeto
2. Atualize as referências no script `player.gd` se necessário

### Implementação do Joystick Virtual

Para adicionar o joystick virtual a uma cena:

```gdscript
# 1. Adicione o nó TouchScreenJoystick à sua cena
var joystick = TouchScreenJoystick.new()
add_child(joystick)

# 2. Configure o joystick conforme necessário
joystick.use_textures = true
joystick.mode = TouchScreenJoystick.DYNAMIC
joystick.base_texture = preload("res://assets/interface/joystick_base.png")
joystick.knob_texture = preload("res://assets/interface/joystick_knob.png")

# 3. Conecte-se ao sinal de entrada do joystick
joystick.joystick_input.connect(_on_joystick_input)

# 4. Processe a entrada do joystick
func _on_joystick_input(vector):
    # vector é um Vector2 normalizado indicando a direção
    velocity = vector * 200
    move_and_slide()
```

## Integração de Ambos os Sistemas

Para criar um personagem que responda tanto ao teclado quanto ao joystick virtual:

```gdscript
extends CharacterBody2D

@export var speed = 200

func _physics_process(delta):
    # Pega entrada do teclado
    var keyboard_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Se não houver entrada do teclado, usa o joystick (se disponível)
    if keyboard_dir == Vector2.ZERO and has_node("TouchScreenJoystick"):
        var joystick = $TouchScreenJoystick
        if joystick.is_pressed():
            keyboard_dir = joystick.get_output()
    
    # Normaliza e aplica velocidade
    if keyboard_dir != Vector2.ZERO:
        velocity = keyboard_dir.normalized() * speed
    else:
        velocity = velocity.move_toward(Vector2.ZERO, speed)
    
    # Move o personagem
    move_and_slide()
```

## Sistema de Animação do Personagem

O sistema de animação foi aprimorado para oferecer transições suaves e um comportamento mais realista do personagem em diferentes estados.

### Principais Componentes do Sistema de Animação

- **Animações Direcionais**: O personagem possui animações específicas para cada direção (cima, baixo, esquerda, direita)
- **Transições de Estado**: Transições suaves entre movimento e estados parados
- **Sistema de Idle**: Animações especiais após períodos de inatividade
- **Prevenção de Deslizamento Visual**: Início de movimento a partir do segundo frame para evitar efeito de deslizamento

### Estrutura de Animação

```gdscript
@onready var sprite = $Sprite2D
var is_moving = false
var last_direction = Vector2.DOWN  # Armazena a última direção do movimento
var was_idle_last_frame = true     # Controla se o jogador estava parado no frame anterior
const IDLE_TIMEOUT = 10.0          # Tempo até mudar para animação "sleeping"
var idle_timer = 0.0               # Contador de tempo ocioso
```

### Atualização de Animação em Movimento

```gdscript
func update_animation(direction: Vector2) -> void:
    if not sprite:
        return
        
    var starting_frame = 0
    
    # Se o jogador estava parado e agora está se movendo, começamos no segundo frame (índice 1)
    # Isso evita o efeito de "deslizamento" quando o jogador começa a andar
    if was_idle_last_frame:
        starting_frame = 1
        was_idle_last_frame = false
    
    # Determina a animação com base na direção principal do movimento
    if abs(direction.x) > abs(direction.y):
        # Movimento horizontal
        if direction.x > 0:
            sprite.play("direita")
        else:
            sprite.play("esquerda")
    else:
        # Movimento vertical
        if direction.y > 0:
            sprite.play("baixo")
        else:
            sprite.play("cima")
    
    # Configura o frame inicial para evitar deslizamento
    if starting_frame > 0 and sprite.sprite_frames.get_frame_count(sprite.animation) > starting_frame:
        sprite.frame = starting_frame
```

## Melhores Práticas

- **Separação de Responsabilidades**: Mantenha a lógica de entrada separada da lógica de movimento
- **Detecção de Plataforma**: Use `OS.get_name()` para detectar a plataforma e ativar o joystick apenas em dispositivos móveis
- **Desempenho**: Use `move_toward()` para suavizar o movimento e evitar mudanças bruscas
- **Configuração**: Use variáveis `@export` para permitir ajustes no Editor Godot

### Sistema de Manutenção de Orientação

Um dos recursos implementados é a manutenção da orientação do personagem quando ele para de se mover. Isso é realizado através da função `play_idle_in_direction`:

```gdscript
func play_idle_in_direction(direction: Vector2) -> void:
    if not sprite:
        return
    
    # Determina qual animação de "parado" usar com base na última direção de movimento
    var animation_name = ""
    
    if abs(direction.x) > abs(direction.y):
        # Direção horizontal
        if direction.x > 0:
            animation_name = "direita"
        else:
            animation_name = "esquerda"
    else:
        # Direção vertical
        if direction.y > 0:
            animation_name = "baixo"
        else:
            animation_name = "cima"
    
    # Define a animação e para no primeiro frame
    if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
        sprite.stop()
        sprite.animation = animation_name
        sprite.frame = 0
        was_idle_last_frame = true  # Importante para a próxima vez que se mover
    else:
        sprite.stop()
        sprite.animation = "default"
        sprite.frame = 0
```

### Sistema de Idle Progressivo

O sistema implementa um comportamento de idle progressivo, onde o personagem muda para diferentes animações após períodos de inatividade:

```gdscript
# Em _physics_process, quando o jogador está parado
if not is_moving:
    # Incrementa o temporizador de inatividade
    idle_timer += delta
    
    # Após 5 segundos, muda para a animação "idle" se não estiver em uma animação especial
    if idle_timer > 5.0 and sprite and sprite.animation != "idle" and sprite.animation != "sleeping":
        sprite.play("idle")
        
    # Após o tempo definido em IDLE_TIMEOUT, muda para "sleeping"
    elif idle_timer > IDLE_TIMEOUT and sprite and sprite.animation != "sleeping":
        sprite.play("sleeping")
```

## Detecção Precisa de Movimento

Para garantir que a animação responda corretamente ao movimento do jogador, implementamos uma verificação precisa de movimento:

```gdscript
func is_actually_moving() -> bool:
    return velocity.length_squared() > 0.01  # Um pequeno valor para evitar imprecisões
```

## Limitações Atuais

- O sistema atual não implementa controles de gamepad
- Não há suporte para múltiplos jogadores
- As transições entre animações diferentes ainda podem ser melhoradas

## Planos Futuros

- Implementar suporte a gamepad
- Adicionar sistema de corrida e ações especiais
- Melhorar sistema de animação com blendtree
- Adicionar efeitos de som ao movimento
- Implementar sistema de passos e sons de deslocamento

## Integração Avançada de Sistemas de Entrada e Interação

O sistema de controle do jogador foi atualizado para lidar de forma inteligente com diferentes fontes de entrada e considerar o contexto do jogo:

### Verificação de Diálogos Ativos

O sistema verifica automaticamente se há diálogos ativos para evitar que o jogador se mova durante conversas:

```gdscript
func is_joystick_visible() -> bool:
    # Tenta usar o GameUtils singleton para verificar diálogos ativos
    if Engine.has_singleton("GameUtils"):
        var game_utils = Engine.get_singleton("GameUtils") 
        if game_utils.has_method("is_dialogue_active") and game_utils.is_dialogue_active():
            return false
    
    # Verifica a visibilidade do joystick
    var joystick = find_joystick()
    if joystick:
        var parent = joystick.get_parent()
        return parent and parent.visible
    return false
```

### Sistema de Interação Universal

O jogador também possui um sistema de interação com objetos no mundo:

```gdscript
# Sistema de interação universal
var objeto_interagivel_atual = null
var pode_interagir = false
var raio_interacao = 100.0
signal interacao_realizada(objeto)

# Verifica objetos interagíveis no raio de alcance
func verificar_objetos_interagiveis() -> void:
    var proximo_objeto = encontrar_objeto_interagivel_proximo()
    
    if proximo_objeto != objeto_interagivel_atual:
        objeto_interagivel_atual = proximo_objeto
        atualizar_botao_interacao()
```

### Tratamento de Eventos de Entrada

O sistema responde a diferentes tipos de entrada e mantém o estado de animação consistente:

```gdscript
func _input(event: InputEvent) -> void:
    # Só processa input se o joystick estiver visível (controle habilitado)
    if is_joystick_visible() and (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
        if event.is_pressed():
            # Se qualquer tecla foi pressionada enquanto está em estado idle/sleeping
            if sprite and (sprite.animation == "sleeping" or sprite.animation == "idle"):
                # Volta para o estado de parado, olhando na última direção
                play_idle_in_direction(last_direction)
                idle_timer = 0.0
                was_idle_last_frame = true  # Importante para a próxima animação de movimento
```

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

## Animações do Personagem

Para integrar animações com o sistema de controle:

```gdscript
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _process(delta):
    # Determina a animação baseada no movimento
    if velocity.length() > 10:
        animation_player.play("walk")
        
        # Vira o sprite na direção do movimento
        if velocity.x < 0:
            sprite.flip_h = true
        elif velocity.x > 0:
            sprite.flip_h = false
    else:
        animation_player.play("idle")
```

## Melhores Práticas

- **Separação de Responsabilidades**: Mantenha a lógica de entrada separada da lógica de movimento
- **Detecção de Plataforma**: Use `OS.get_name()` para detectar a plataforma e ativar o joystick apenas em dispositivos móveis
- **Desempenho**: Use `move_toward()` para suavizar o movimento e evitar mudanças bruscas
- **Configuração**: Use variáveis `@export` para permitir ajustes no Editor Godot

## Limitações Atuais

- O sistema atual não implementa controles de gamepad
- Não há suporte para múltiplos jogadores
- As animações são básicas e precisam ser expandidas

## Planos Futuros

- Implementar suporte a gamepad
- Adicionar sistema de corrida e ações especiais
- Melhorar sistema de animação com blendtree
- Adicionar efeitos de som ao movimento

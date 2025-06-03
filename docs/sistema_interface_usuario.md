# Sistema de Menu e Interface do Usuário - Documentação

## Visão Geral
O Projeto Code implementa um sistema abrangente de menus e interfaces do usuário que gerenciam a navegação do jogador pelo jogo. O sistema inclui menu principal, menu de pausa, configurações e elementos de interface durante o gameplay.

## Componentes Principais

### Menu Principal
Localização: `scenes/main menu/MenuPrincipal.tscn`

O menu principal é a primeira interface que o jogador vê ao iniciar o jogo. Contém:
- Título do jogo
- Botões para iniciar um novo jogo
- Acesso às configurações
- Opção para sair do jogo
- Efeitos visuais e animações de fundo

#### Camera2D no Menu Principal
Localização: `scenes/main menu/camera_2d.gd`

Script que controla efeitos de câmera no menu principal, possivelmente implementando:
- Movimentos suaves da câmera
- Zoom ou efeitos visuais
- Transições entre elementos do menu

### Menu de Pausa
Localização: `scenes/menu pausa/MenuPausa.tscn`

Interface que aparece quando o jogo é pausado, contendo:
- Botões para retornar ao jogo
- Acesso às configurações
- Opção para voltar ao menu principal
- Controles de áudio rápidos

### Configurações
Localização: `scenes/configurações/config.tscn`

Menu de configurações que permite ao jogador personalizar sua experiência:
- Controles de volume
- Configurações de gráficos
- Opções de controle
- Preferências gerais do jogo

### Elementos de Interface

#### BotãoMenu
Localização: `assets/interface/buttons/BotãoMenu.tscn`

Um componente reutilizável para botões de menu que provavelmente inclui:
- Visual personalizado
- Efeitos de hover/click
- Sons de feedback
- Sistema de foco para navegação por teclado/gamepad

## Sistema de Transição

O projeto utiliza um sistema de transição global registrado como autoload:
```gdscript
# De project.godot
[autoload]
TransitionScreen="*res://scenes/global/effects/transition_screen.tscn"
```

Este sistema é utilizado para criar transições suaves entre menus e cenas do jogo.

## Fluxo de Navegação

1. **Menu Principal → Jogo**
   - O jogador seleciona "Novo Jogo"
   - Uma transição é acionada
   - O prólogo é carregado

2. **Jogo → Menu de Pausa**
   - O jogador pressiona ESC durante o gameplay
   - O jogo é pausado (process_mode = PROCESS_MODE_DISABLED)
   - O menu de pausa é exibido

3. **Menu de Pausa → Configurações**
   - O jogador seleciona "Configurações"
   - O menu de pausa é ocultado
   - O menu de configurações é mostrado
   - O estado anterior é salvo para retorno

## Como Usar o Sistema de Menu

### Adicionar um Novo Botão ao Menu Principal:

```gdscript
# 1. Instancie o componente BotãoMenu em sua cena
var novo_botao = load("res://assets/interface/buttons/BotãoMenu.tscn").instance()
$ContainerBotoes.add_child(novo_botao)

# 2. Configure o botão
novo_botao.text = "Nome do Botão"
novo_botao.connect("pressed", self, "_on_novo_botao_pressed")

# 3. Implemente a função de callback
func _on_novo_botao_pressed() -> void:
    # Ação a ser executada quando o botão for pressionado
    print("Botão pressionado!")
```

### Implementar uma Nova Tela de Menu:

1. Crie uma nova cena com um nó raiz (Control ou CanvasLayer)
2. Adicione elementos de interface (botões, rótulos, etc.)
3. Crie um script para gerenciar a lógica da tela
4. Conecte os sinais dos botões às funções adequadas
5. Adicione a nova cena ao sistema de orquestrador para gerenciamento de transições

```gdscript
# Exemplo de script para uma nova tela de menu
extends Control

signal back_pressed

func _ready() -> void:
    $BackButton.connect("pressed", self, "_on_back_button_pressed")

func _on_back_button_pressed() -> void:
    emit_signal("back_pressed")
    
func show_with_effect() -> void:
    # Efeito de aparecimento
    modulate = Color(1, 1, 1, 0)
    visible = true
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
```

## Estilo Visual

O sistema de menu utiliza:
- Fontes específicas como Daydream (`.../fonts/daydream_3/Daydream.ttf`) e Pixellari (`.../fonts/pixellari/Pixellari.ttf`)
- Ícones para botões e funcionalidades (`assets/interface/icons/`)
- Esquema de cores consistente
- Elementos com estilo pixel art

## Melhores Práticas

- **Consistência**: Mantenha uma aparência visual consistente em todos os menus
- **Feedback**: Forneça feedback visual e sonoro para todas as interações
- **Acessibilidade**: Permita navegação por teclado/gamepad além do mouse
- **Resposta**: Garanta que os menus sejam responsivos e se adaptem a diferentes resoluções
- **Transições**: Use transições suaves entre menus para melhorar a experiência

## Limitações Atuais

- O sistema não implementa completamente a responsividade para todas as proporções de tela
- Faltam opções de acessibilidade como redimensionamento de texto
- Não há suporte completo para navegação por gamepad em todos os menus

## Recursos Avançados a Implementar

- Sistema de salvamento de configurações do jogador
- Temas personalizáveis para a interface
- Suporte multilíngue para textos de interface
- Animações mais elaboradas para transições de tela

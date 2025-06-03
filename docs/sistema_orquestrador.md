# Sistema de Gerenciamento de Cenas (Orquestrador) - Documentação

## Visão Geral
O sistema de gerenciamento de cenas, também chamado de Orquestrador, é responsável por controlar o fluxo do jogo, transições entre cenas e estados do jogo no Projeto Code. Este sistema é central para toda a arquitetura do jogo e gerencia a navegação entre os diferentes componentes como menus, prólogo e gameplay.

## Componentes Principais

### Game.gd
Localização: `scenes/orquestrador/game.gd`

Este script é o controlador principal de todo o fluxo do jogo, responsável por:
- Gerenciar estados do jogo (menu, prólogo, gameplay, pausa)
- Controlar a ativação e desativação de cenas
- Processar transições entre estados
- Gerenciar o sistema de pausa

#### Estados do Jogo
```gdscript
enum GameState {
    NONE,
    MENU,
    PROLOGUE,
    PLAYING,
    PAUSED,
    OPTIONS,
    CONFIG_FROM_PAUSE 
}
```

#### Métodos Importantes:
- `_setup_scenes_array()`: Configura o array de cenas disponíveis
- `_initialize_game_state_and_scenes()`: Inicializa as cenas e estados do jogo
- `_connect_all_scene_signals()`: Conecta todos os sinais necessários entre cenas
- `change_state(new_state)`: Muda o estado atual do jogo para um novo estado
- `activate_scene(scene)`: Ativa uma cena específica e desativa as outras
- `transition_to_scene(next_scene)`: Realiza a transição entre cenas com efeitos

### Orquestrador.gd
Localização: `scenes/orquestrador/Orquestrador.gd`

Este script oferece uma camada de compatibilidade com código legado e implementa:
- Sistema alternativo de gerenciamento de cenas
- Métodos para mostrar/ocultar cenas específicas
- Interface de compatibilidade com sistemas anteriores

#### Métodos Importantes:
- `_setup_legacy_system()`: Configura o sistema legado de gerenciamento de cenas
- `_hide_all_scenes()`: Oculta todas as cenas registradas
- `_show_scene(scene)`: Mostra uma cena específica e a define como atual
- `scene_transition(next_scene)`: Realiza transição simples entre cenas

## Estrutura da Cena Game.tscn

A cena principal `Game.tscn` contém:
- Nós para cada seção principal do jogo (MenuPrincipal, Prologue, Gameplay)
- Sistemas de efeitos e transições
- Configurações globais

## Fluxo de Funcionamento

1. **Inicialização**:
   - O script `game.gd` configura todas as cenas disponíveis
   - Define o estado inicial como MENU
   - Desativa todas as cenas exceto a do menu principal

2. **Transições**:
   - Quando o jogador interage com um botão (ex: "Novo Jogo")
   - O sistema muda o estado (ex: MENU -> PROLOGUE)
   - A cena anterior é desativada e a nova cena é ativada
   - Efeitos de transição são aplicados se configurados

3. **Estados Especiais**:
   - PAUSED: Ativa o menu de pausa sobreposto ao gameplay
   - OPTIONS: Ativa o menu de opções
   - O estado anterior é armazenado para poder retornar

## Como Usar o Sistema de Orquestrador

### Registrar uma Nova Cena:

Para adicionar uma nova cena ao sistema de gerenciamento:

```gdscript
# Em game.gd, adicione sua cena ao método _setup_scenes_array()
func _setup_scenes_array() -> void:
    scenes = [
        menu_principal,
        prologue,
        gameplay,
        menu_opcoes,
        sua_nova_cena  # Adicione aqui
    ]
    scenes = scenes.filter(func(scene: Node) -> bool: return scene != null)
```

### Adicionar um Novo Estado:

Para adicionar um novo estado ao sistema:

```gdscript
# Em game.gd, adicione o novo estado ao enum GameState
enum GameState {
    NONE,
    MENU,
    PROLOGUE,
    PLAYING,
    PAUSED,
    OPTIONS,
    CONFIG_FROM_PAUSE,
    SEU_NOVO_ESTADO  # Adicione aqui
}

# Em seguida, adicione o tratamento do novo estado em change_state()
func change_state(new_state: GameState) -> void:
    # ...código existente...
    
    match new_state:
        # ...casos existentes...
        
        GameState.SEU_NOVO_ESTADO:
            # Lógica para o novo estado
            activate_scene(sua_nova_cena)
```

### Solicitar Mudança de Estado:

Para solicitar uma mudança de estado a partir de outra cena:

```gdscript
# Em qualquer script que precise mudar o estado do jogo
var game_manager = get_node("/root/Game")
if game_manager:
    game_manager.change_state(game_manager.GameState.PLAYING)
```

## Transições entre Cenas

O sistema suporta transições suavizadas entre cenas usando o nó global `TransitionScreen`:

```gdscript
# Exemplo de como uma transição é realizada
func transition_to_scene(next_scene: Node) -> void:
    if is_transitioning:
        return
    
    is_transitioning = true
    
    # Fade out
    await TransitionScreen.fade_to_black()
    
    # Mudança de cena
    activate_scene(next_scene)
    
    # Fade in
    await TransitionScreen.fade_from_black()
    
    is_transitioning = false
```

## Melhores Práticas

- **Sinalização**: Use sinais para comunicação entre cenas e o orquestrador
- **Limpeza**: Certifique-se de limpar o estado ao sair de uma cena
- **Estados**: Não altere estados diretamente, use métodos do game.gd
- **Verificações**: Sempre verifique se o orquestrador está disponível antes de tentar usá-lo

## Limitações Atuais

- O sistema atual não suporta cenas carregadas dinamicamente (todas devem ser pré-carregadas)
- Não há sistema para empilhar cenas (ex: para menus aninhados)
- O sistema de transições é limitado a fades simples

## Planos Futuros

- Implementar carregamento dinâmico de cenas para reduzir uso de memória
- Adicionar sistema de pilha de cenas para menus aninhados
- Expandir opções de transições com mais efeitos visuais
- Melhorar a integração com sistema de salvamento

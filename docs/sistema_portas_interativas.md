# Sistema de Portas Interativas

Este sistema implementa um mecanismo padronizado para criar portas que permitem ao jogador transitar entre cenas no jogo.

## Como funciona

O sistema é construído sobre duas classes principais:
- **InteractiveObject**: Classe base para todos os objetos interativos
- **InteractiveDoor**: Especialização que implementa a transição entre cenas

## Como adicionar uma porta a uma cena

### Método 1: Adicionar a uma cena existente

1. Você pode criar um script que adiciona as portas dinamicamente, como implementado nos exemplos:
   - `gameplay_doors.gd` para a cena Gameplay
   - `prologue_doors.gd` para a cena do Prólogo

2. Exemplo de como adicionar um script de porta a uma cena:
```gdscript
# No script _ready() da sua cena
var door_manager = Node.new()
door_manager.name = "DoorManager"
door_manager.set_script(load("caminho/para/script_de_portas.gd"))
add_child(door_manager)
```

### Método 2: Adicionar manualmente no editor

1. Adicione um `Node2D` para servir como nó da porta
2. Adicione um `Sprite2D` como filho (opcional, para visualização)
3. Adicione um nó com o script `interactive_door.gd` como filho
4. Configure as propriedades da porta:
   - `target_scene`: Caminho para a cena alvo
   - `transition_effect`: Tipo de efeito ("fade", "loading", "instant")
   - `is_locked`: Se a porta está trancada
   - `need_key`: Nome da chave necessária (se trancada)
   - `interaction_prompt`: Texto exibido ao se aproximar

## Interação do Jogador

O jogador pode interagir com a porta de duas maneiras:
1. Pressionando a tecla `E` quando próximo da porta
2. Clicando no botão de interação na interface móvel

## Sistema de Chaves (Opcional)

Para portas trancadas, configure as propriedades:
- `is_locked = true`
- `need_key = "nome_da_chave"`

Um jogador com a chave correta pode usar a função `try_unlock("nome_da_chave")` para destrancar a porta.

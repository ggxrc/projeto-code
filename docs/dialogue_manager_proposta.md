# DialogueManager - Proposta de Implementação

Este documento apresenta uma proposta detalhada para a implementação do novo sistema de gerenciamento de diálogos, visando resolver a duplicação entre `prologue.gd` e `prologue_dialogue_manager.gd`.

## Visão Geral da Solução

A solução proposta é criar uma classe `DialogueManager` que:
- Centraliza toda a lógica de gerenciamento de diálogo
- Separa dados de diálogo da lógica de apresentação
- Fornece uma interface consistente para interações com diálogos
- Elimina a duplicação de código entre scripts

## Estrutura de Classes

### DialogueManager (Classe Principal)

```gdscript
extends Node
class_name DialogueManager

# Sinais
signal dialogue_started
signal dialogue_ended
signal dialogue_line_displayed(text)
signal dialogue_choices_displayed(choices)
signal player_choice_made(choice_index, choice_text)
signal dialogue_state_changed(old_state, new_state)

# Tipos de Diálogo
enum DialogueBoxType {
    STANDARD,
    CHOICE,
    DESCRIPTION
}

# Estados do Diálogo
enum DialogueState {
    INACTIVE,
    PLAYING,
    WAITING_FOR_INPUT,
    WAITING_FOR_CHOICE,
    ENDING
}

# Caminhos de Narração
enum NarrationPath {
    STANDARD,
    ALTERNATE
}

# Referências para caixas de diálogo
var dialogue_box
var choice_dialogue_box
var description_box

# Estado atual
var current_state: DialogueState = DialogueState.INACTIVE
var current_path: NarrationPath = NarrationPath.STANDARD
var current_dialogue_data: Dictionary = {}
var current_line_index: int = 0
var selected_choice: int = -1
var incorrect_choices: Array = []

# Depuração
@export var debug_mode: bool = false

# Inicialização
func _ready():
    pass

# Configuração das caixas de diálogo
func setup_dialogue_boxes(std_box, choice_box, desc_box):
    dialogue_box = std_box
    choice_dialogue_box = choice_box
    description_box = desc_box
    
    # Conectar sinais das caixas de diálogo
    if dialogue_box:
        dialogue_box.dialogue_line_finished.connect(_on_dialogue_line_finished)
    
    if choice_dialogue_box:
        choice_dialogue_box.choice_selected.connect(_on_choice_selected)
    
    if description_box:
        description_box.dialogue_line_finished.connect(_on_dialogue_line_finished)

# Carrega dados de diálogo (formato Dictionary)
func load_dialogue(dialogue_data: Dictionary) -> bool:
    if not _validate_dialogue_data(dialogue_data):
        push_error("DialogueManager: Dados de diálogo inválidos")
        return false
    
    current_dialogue_data = dialogue_data.duplicate(true)
    current_line_index = 0
    current_state = DialogueState.INACTIVE
    current_path = NarrationPath.STANDARD
    incorrect_choices = []
    
    _log("Diálogo carregado com sucesso: %s linhas" % [_get_current_dialogue_sequence().size()])
    return true

# Inicia a sequência de diálogo
func start_dialogue() -> void:
    if current_state != DialogueState.INACTIVE:
        _log("Tentando iniciar diálogo já ativo")
        return
    
    if current_dialogue_data.is_empty():
        push_error("DialogueManager: Tentando iniciar diálogo sem dados")
        return
    
    current_state = DialogueState.PLAYING
    dialogue_started.emit()
    _log("Diálogo iniciado no caminho: %s" % [NarrationPath.keys()[current_path]])
    
    _process_current_line()

# Avança para a próxima linha de diálogo
func advance_dialogue() -> void:
    if current_state != DialogueState.WAITING_FOR_INPUT:
        _log("Tentando avançar diálogo em estado não-esperando: %s" % [DialogueState.keys()[current_state]])
        return
    
    current_line_index += 1
    _process_current_line()

# Seleciona uma opção em diálogo de escolha
func select_choice(choice_index: int) -> void:
    if current_state != DialogueState.WAITING_FOR_CHOICE:
        _log("Tentando selecionar opção em estado não-esperando-escolha: %s" % [DialogueState.keys()[current_state]])
        return
    
    selected_choice = choice_index
    
    var choices = _get_current_choices()
    if choices.is_empty() or choice_index < 0 or choice_index >= choices.size():
        push_error("DialogueManager: Índice de escolha inválido: %d" % [choice_index])
        return
    
    var choice_text = choices[choice_index]
    player_choice_made.emit(choice_index, choice_text)
    
    # Processar resposta à escolha
    _process_choice_response(choice_index, choice_text)

# Marca uma opção como incorreta
func mark_choice_as_incorrect(choice_text: String) -> void:
    if not choice_text in incorrect_choices:
        incorrect_choices.append(choice_text)
        _log("Marcada opção como incorreta: %s" % [choice_text])

# Termina a sequência de diálogo
func end_dialogue() -> void:
    _change_state(DialogueState.ENDING)
    
    # Esconder todas as caixas de diálogo
    if dialogue_box:
        dialogue_box.hide_box()
    if choice_dialogue_box:
        choice_dialogue_box.hide_box()
    if description_box:
        description_box.hide_box()
    
    current_state = DialogueState.INACTIVE
    dialogue_ended.emit()
    _log("Diálogo finalizado")

# Processar linha atual
func _process_current_line() -> void:
    var sequence = _get_current_dialogue_sequence()
    
    # Verificar se chegamos ao fim da sequência
    if current_line_index >= sequence.size():
        _process_next_dialogue_section()
        return
    
    var line = sequence[current_line_index]
    
    # Processar linha com base no tipo
    if _is_choice_prompt(line):
        _show_choices()
    elif _is_description_text(line):
        _show_description(line)
    else:
        _show_dialogue(line)

# Determina o tipo de box a usar para uma linha
func _determine_box_type(line: String) -> DialogueBoxType:
    if _is_description_text(line):
        return DialogueBoxType.DESCRIPTION
    return DialogueBoxType.STANDARD

# Busca a sequência atual com base no estado e caminho
func _get_current_dialogue_sequence() -> Array:
    # Implementação depende da estrutura de dados
    # Exemplo simplificado:
    if current_dialogue_data.has("sequences"):
        var key = "standard"
        if current_path == NarrationPath.ALTERNATE:
            key = "alternate"
        
        if current_dialogue_data["sequences"].has(key):
            return current_dialogue_data["sequences"][key]
    
    # Fallback
    return []

# Busca as escolhas atuais
func _get_current_choices() -> Array:
    # Implementação depende da estrutura de dados
    # Exemplo simplificado:
    if current_dialogue_data.has("choices"):
        var state_key = str(current_state)
        if current_dialogue_data["choices"].has(state_key):
            var choices = current_dialogue_data["choices"][state_key].duplicate()
            
            # Remover opções incorretas (se necessário)
            if current_dialogue_data.get("remove_incorrect_choices", false):
                for text in incorrect_choices:
                    if text in choices:
                        choices.erase(text)
                        
            return choices
    
    # Fallback
    return []

# Processa a resposta à escolha do usuário
func _process_choice_response(choice_index: int, choice_text: String) -> void:
    var responses_key = "choice_responses"
    
    if current_dialogue_data.has(responses_key):
        var state_key = str(current_state)
        if current_dialogue_data[responses_key].has(state_key):
            var responses = current_dialogue_data[responses_key][state_key]
            
            # Tentar encontrar resposta pelo texto da escolha primeiro
            if responses.has(choice_text):
                _show_dialogue(responses[choice_text])
            # Fallback para índice
            elif responses.has(str(choice_index)):
                _show_dialogue(responses[str(choice_index)])
            else:
                push_error("DialogueManager: Sem resposta definida para escolha: %s" % [choice_text])
                advance_dialogue()
                return
            
            # Verificar se esta escolha redefine o caminho
            _check_for_path_change(choice_index, choice_text)
            return
    
    # Se não há resposta definida, apenas avançar
    push_warning("DialogueManager: Sem definição de respostas para escolhas no estado atual")
    advance_dialogue()

# Verifica se uma escolha deve causar mudança de caminho
func _check_for_path_change(choice_index: int, choice_text: String) -> void:
    var paths_key = "choice_paths"
    
    if current_dialogue_data.has(paths_key):
        var state_key = str(current_state)
        if current_dialogue_data[paths_key].has(state_key):
            var paths = current_dialogue_data[paths_key][state_key]
            
            # Verificar pelo texto da escolha
            if paths.has(choice_text):
                var new_path = paths[choice_text]
                _change_narration_path(new_path)
            # Fallback para índice
            elif paths.has(str(choice_index)):
                var new_path = paths[str(choice_index)]
                _change_narration_path(new_path)

# Altera o caminho da narração
func _change_narration_path(new_path_name: String) -> void:
    var old_path = current_path
    
    # Converter string para enum
    for path_value in NarrationPath.values():
        if NarrationPath.keys()[path_value].to_lower() == new_path_name.to_lower():
            current_path = path_value
            _log("Caminho alterado: %s -> %s" % [NarrationPath.keys()[old_path], NarrationPath.keys()[current_path]])
            return
    
    push_error("DialogueManager: Nome de caminho inválido: %s" % [new_path_name])

# Mostra texto em caixa de diálogo padrão
func _show_dialogue(text: String) -> void:
    if not dialogue_box:
        push_error("DialogueManager: dialogue_box não configurado")
        return
    
    dialogue_box.visible = true
    if choice_dialogue_box:
        choice_dialogue_box.visible = false
    if description_box:
        description_box.visible = false
        
    dialogue_box.show_line(text)
    dialogue_line_displayed.emit(text)
    _change_state(DialogueState.WAITING_FOR_INPUT)

# Mostra texto em caixa de descrição
func _show_description(text: String) -> void:
    # Se não temos caixa de descrição específica, usar caixa padrão
    if not description_box:
        _show_dialogue(text)
        return
    
    description_box.visible = true
    if dialogue_box:
        dialogue_box.visible = false
    if choice_dialogue_box:
        choice_dialogue_box.visible = false
        
    description_box.show_line(text)
    dialogue_line_displayed.emit(text)
    _change_state(DialogueState.WAITING_FOR_INPUT)

# Mostra opções de escolha
func _show_choices() -> void:
    if not choice_dialogue_box:
        push_error("DialogueManager: choice_dialogue_box não configurado")
        return
    
    choice_dialogue_box.visible = true
    if dialogue_box:
        dialogue_box.visible = false
    if description_box:
        description_box.visible = false
    
    var choices = _get_current_choices()
    var title = current_dialogue_data.get("choice_titles", {}).get(str(current_state), "")
    
    choice_dialogue_box.show_choices(choices, title)
    dialogue_choices_displayed.emit(choices)
    _change_state(DialogueState.WAITING_FOR_CHOICE)

# Verifica se linha representa uma solicitação de escolha
func _is_choice_prompt(text: String) -> bool:
    # Esta é uma implementação simples. 
    # Na versão completa, poderia ser baseada em tags ou estruturas específicas.
    return text == "<CHOICE>"

# Verifica se texto é de descrição/contexto
func _is_description_text(text: String) -> bool:
    # Verificar texto entre asteriscos
    if text.begins_with("*") and text.ends_with("*"):
        return true
        
    # Verificar texto começando com asterisco
    if text.begins_with("*"):
        return true
    
    # Verificar comentários
    if text.begins_with("#"):
        return true
        
    return false

# Avança para a próxima seção do diálogo (após uma sequência)
func _process_next_dialogue_section() -> void:
    # Implementação depende da estrutura de dados
    # Na implementação real, isso consultaria a estrutura para determinar
    # qual estado ou seção deve vir a seguir
    
    # Exemplo simples: verificar se há uma próxima seção definida
    if current_dialogue_data.has("next_sections"):
        var current_key = str(current_state)
        if current_dialogue_data["next_sections"].has(current_key):
            var next_section = current_dialogue_data["next_sections"][current_key]
            
            if typeof(next_section) == TYPE_STRING and next_section.to_lower() == "end":
                end_dialogue()
                return
            elif typeof(next_section) == TYPE_INT:
                # Assumir que é um novo estado DialogueState
                _change_state(next_section)
                current_line_index = 0
                _process_current_line()
                return
    
    # Por padrão, concluir o diálogo se não há instruções específicas
    end_dialogue()

# Altera o estado do diálogo
func _change_state(new_state: DialogueState) -> void:
    var old_state = current_state
    current_state = new_state
    
    if old_state != new_state:
        dialogue_state_changed.emit(old_state, new_state)
        _log("Estado alterado: %s -> %s" % [DialogueState.keys()[old_state], DialogueState.keys()[new_state]])

# Valida a estrutura de dados de diálogo
func _validate_dialogue_data(data: Dictionary) -> bool:
    # Implementação básica
    if not data.has("sequences") or not data["sequences"].has("standard"):
        return false
    return true

# Callbacks para eventos de caixas de diálogo
func _on_dialogue_line_finished() -> void:
    # Linhas de descrição avançam automaticamente
    if current_state == DialogueState.WAITING_FOR_INPUT and _is_description_text(_get_current_dialogue_sequence()[current_line_index]):
        advance_dialogue()

func _on_choice_selected(choice_index: int) -> void:
    select_choice(choice_index)

# Função de log para debug
func _log(message: String) -> void:
    if debug_mode:
        print("[DialogueManager] " + message)
```

### DialogueData (Recurso)

```gdscript
extends Resource
class_name DialogueData

# Metadados
@export var dialogue_id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

# Sequências de diálogo
@export var sequences: Dictionary = {
    "standard": [],   # Caminho padrão
    "alternate": []   # Caminho alternativo
}

# Opções de escolha por estado
@export var choices: Dictionary = {}

# Respostas às escolhas
@export var choice_responses: Dictionary = {}

# Títulos para prompts de escolha
@export var choice_titles: Dictionary = {}

# Mapeamento de escolhas para caminhos
@export var choice_paths: Dictionary = {}

# Próximas seções após cada estado
@export var next_sections: Dictionary = {}

# Flags
@export var remove_incorrect_choices: bool = true

# Funções utilitárias para adicionar dados facilmente
func add_dialogue_line(line: String, path: String = "standard") -> void:
    if not sequences.has(path):
        sequences[path] = []
    sequences[path].append(line)

func set_choices_for_state(state: int, choices_array: Array) -> void:
    choices[str(state)] = choices_array

func set_choice_responses(state: int, responses: Dictionary) -> void:
    choice_responses[str(state)] = responses

func set_choice_title(state: int, title: String) -> void:
    choice_titles[str(state)] = title

func set_choice_path_mapping(state: int, choice_index_or_text, path: String) -> void:
    if not choice_paths.has(str(state)):
        choice_paths[str(state)] = {}
    
    if choice_index_or_text is int:
        choice_paths[str(state)][str(choice_index_or_text)] = path
    else:
        choice_paths[str(state)][choice_index_or_text] = path

func set_next_section(state: int, next_section) -> void:
    next_sections[str(state)] = next_section
```

## Exemplo de Uso

```gdscript
# No script de uma cena (ex: prologue.gd)
extends Node

@onready var dialogue_manager = $DialogueManager
@onready var dialogue_box = $DialogueBox
@onready var choice_dialogue_box = $ChoiceDialogueBox
@onready var description_box = $DescriptionBox

func _ready():
    # Configurar caixas de diálogo
    dialogue_manager.setup_dialogue_boxes(dialogue_box, choice_dialogue_box, description_box)
    
    # Conectar sinais
    dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
    
    # Criar dados de diálogo
    var dialogue_data = _create_prologue_dialogue()
    
    # Carregar diálogo
    if dialogue_manager.load_dialogue(dialogue_data):
        # Iniciar sequência automaticamente ou aguardar algum evento
        dialogue_manager.start_dialogue()

func _on_dialogue_ended():
    print("Diálogo concluído, prosseguindo para próximo passo...")
    # Lógica para continuar o jogo após o diálogo

func _create_prologue_dialogue() -> Dictionary:
    # Criando dados de diálogo programaticamente
    var data = {
        "sequences": {
            "standard": [
                "*Protagonista dormindo*",
                "Aí está nosso faz-tudo, em sua confortável cama.",
                "...",
                "ou deveria ser uma cama... o importante é o conforto",
                "*Ele está dormindo, o que você vai fazer?*",
                "<CHOICE>"  # Marcador especial para mostrar escolhas
            ],
            "alternate": [
                "*Protagonista cai da cama*",
                "Muito bem, você esbagaçou ele no chão, mas, tecnicamente funciona...",
                "Então, o que vem agora?",
                "<CHOICE>"
            ]
        },
        "choices": {
            "5": [  # Estado WAITING_FOR_CHOICE para primeira escolha
                "a) acordar",
                "b) levantar",
                "c) abrir o olho",
                "d) sair da cama"
            ],
            "6": [  # Estado para segunda escolha
                "b) levantar",
                "c) abrir o olho", 
                "d) sair da cama"
            ],
            "7": [  # Estado para escolha no caminho alternativo
                "a) levantar",
                "b) abrir o olho"
            ]
        },
        "choice_titles": {
            "5": "O que você vai fazer?",
            "6": "Agora que ele está acordado, o que vem depois?",
            "7": "O que vem agora?"
        },
        "choice_responses": {
            "5": {
                "a) acordar": "ótimo, está indo no caminho certo",
                "b) levantar": "vai levantar dormindo?",
                "c) abrir o olho": "vai abrir o olho dormindo?",
                "d) sair da cama": "que eu saiba ele não é sonâmbulo"
            },
            "6": {
                "b) levantar": "isso mesmo, agora você levantou",
                "c) abrir o olho": "isso mesmo, agora você abriu o olho",
                "d) sair da cama": "vai sair deitado?"
            },
            "7": {
                "a) levantar": "maravilha, você levantou, mas por que até agora você não abriu o olho?",
                "b) abrir o olho": "de que adianta abrir o olho se você ainda tá no chão?"
            }
        },
        "choice_paths": {
            "5": {
                "a) acordar": "standard",  # Continua no caminho padrão
                # Outros não alteram caminho
            },
            "6": {
                "d) sair da cama": "alternate"  # Muda para caminho alternativo
            }
        },
        "next_sections": {
            "5": 6,  # Após primeira escolha, ir para estado 6
            "6": 8,  # Após segunda escolha, ir para estado 8 (conclusão)
            "7": 8,  # Após escolha no caminho alternativo, ir para conclusão
            "8": "end"  # Fim do diálogo
        },
        "remove_incorrect_choices": true
    }
    
    return data
```

## Vantagens desta Abordagem

1. **Centralização**: Toda a lógica de gerenciamento de diálogo está em um único lugar
2. **Separação de Responsabilidades**: Dados de diálogo são separados da lógica de apresentação
3. **Flexibilidade**: Suporta diferentes tipos de caixas de diálogo e caminhos narrativos
4. **Manutenção**: Facilita correções e extensões do sistema
5. **Reutilização**: Pode ser usado em várias partes do jogo com configurações diferentes

## Próximos Passos para Implementação

1. Criar o script `dialogue_manager.gd` com a classe DialogueManager
2. Criar o script `dialogue_data.gd` com a classe DialogueData
3. Refatorar `prologue.gd` para usar o novo sistema
4. Migrar dados e lógica de diálogo para o formato apropriado
5. Remover código redundante de `prologue_dialogue_manager.gd`
6. Testar o sistema em diferentes cenários
7. Documentar o uso do sistema para outros desenvolvedores

---

*Documento criado em: 08/06/2025*

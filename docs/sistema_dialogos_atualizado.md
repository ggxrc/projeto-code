# Sistema de Diálogos - Documentação

## Visão Geral
O sistema de diálogos do Projeto Code implementa uma forma flexível de exibir conversas e textos narrativos no jogo. O sistema utiliza efeitos de digitação para simular textos sendo escritos em tempo real e permite controle sobre o ritmo da narrativa. Além disso, agora suporta caminhos ramificados, escolhas do jogador e processamento especial para textos de contexto/descrição.

## Componentes Principais

### DialogueBox (dialogue_box.gd)
Localização: `scenes/diálogos/DialogueBox.tscn` e `scenes/diálogos/dialogue_box.gd`

A caixa de diálogo principal que exibe textos de personagens e da narrativa.

#### Funcionalidades principais:
- **Efeito de Digitação**: Exibe o texto caractere por caractere com velocidade ajustável
- **Sinalização**: Emite sinais quando uma linha de diálogo é concluída
- **Controle de Visibilidade**: Métodos para exibir e ocultar a caixa de diálogo
- **Avanço de Texto**: Permite pular ou acelerar a exibição do texto atual
- **Verificação de Estado**: Permite verificar se um texto está sendo digitado no momento

#### Métodos Importantes:
- `show_line(text_content: String, speed: float = 0.03)`: Exibe uma linha de texto com efeito de digitação
- `hide_box()`: Oculta a caixa de diálogo e reinicia seu estado
- `advance_or_skip_typewriter()`: Avança ou pula completamente o efeito de digitação
- `is_typewriting() -> bool`: Retorna se o efeito de digitação está ativo no momento

#### Sinais:
- `dialogue_line_finished`: Emitido quando uma linha de diálogo termina de ser exibida

### DescriptionBox (description_box.gd)
Localização: `scenes/diálogos/DescriptionBox.tscn` e `scenes/diálogos/description_box.gd`

Uma variante da caixa de diálogo utilizada para exibir descrições de objetos, áreas ou eventos no jogo.

### ChoiceDialogueBox (choice_dialogue_box.gd)
Localização: `scenes/diálogos/ChoiceDialogueBox.tscn` e `scenes/diálogos/choice_dialogue_box.gd`

Um componente para exibir opções de escolha para o jogador durante diálogos.

#### Funcionalidades principais:
- **Exibição de Escolhas**: Apresenta botões interativos para o jogador selecionar
- **Título/Pergunta**: Exibe um texto acima das opções (como uma pergunta)
- **Sinalização de Escolha**: Emite sinais quando uma escolha é selecionada

#### Métodos Importantes:
- `show_choices(choices: Array, title: String = "")`: Exibe uma lista de opções de escolha com um título opcional
- `hide_box()`: Oculta a caixa de escolhas e limpa as opções anteriores

#### Sinais:
- `choice_selected(choice_index: int)`: Emitido quando o jogador seleciona uma opção, passando o índice da escolha

## Sistema de Diálogo Interativo no Prólogo

### Visão Geral do Sistema no Prólogo
O prólogo implementa um sistema de diálogo avançado com:

1. **Caminhos Branqueados de Diálogo**:
   - Caminho Amarelo (padrão): Sequência padrão quando o jogador faz escolhas "corretas"
   - Caminho Azul (alternativo): Sequência alternativa quando o jogador escolhe "sair da cama"

2. **Sistema de Escolhas com Feedback**:
   - Opções incorretas são removidas das escolhas disponíveis
   - O jogador recebe feedback imediato sobre suas escolhas
   - Escolhas diferentes levam a diferentes sequências de diálogo

3. **Textos de Contexto/Descrição**:
   - Textos entre asteriscos (ex: `*Protagonista dormindo*`) são tratados como contextos
   - Contextos não são mostrados como diálogo para o jogador
   - O sistema avança automaticamente ao encontrar textos de contexto

4. **Sistema de Interação por Clique**:
   - Indicador visual quando o jogador precisa clicar para continuar
   - Suporte para clique do mouse, toque na tela ou teclas (espaço/enter)
   - Possibilidade de acelerar/pular a digitação do texto

### Estados de Diálogo no Prólogo
O prólogo usa uma máquina de estados para controlar o fluxo de diálogo:

```gdscript
enum DialogueState {
    INTRO,
    FIRST_CHOICE,
    SECOND_CHOICE,
    BLUE_PATH,
    BLUE_PATH_CONTINUATION,
    YELLOW_PATH,
    CONCLUSION
}
```

### Fluxo Lógico do Diálogo

#### Primeira Escolha:
- Se escolher "acordar", avança para a segunda escolha (opção correta)
- Se escolher outra opção, ela é removida das escolhas disponíveis, e o jogador precisa escolher novamente

#### Segunda Escolha:
- Se escolher "sair da cama", vai para o caminho azul (caminho alternativo)
- Se escolher "levantar" ou "abrir o olho", vai para o caminho amarelo correspondente (caminho padrão)
- Se escolher uma opção incorreta, ela é removida das opções disponíveis, e o jogador precisa escolher novamente

#### Caminho Amarelo (padrão):
- Dependendo da escolha anterior (levantar ou abrir o olho), exibe diálogos específicos
- No final, vai para a conclusão padrão

#### Caminho Azul (alternativo):
- O protagonista cai da cama
- Apresenta novas escolhas após cair da cama (levantar ou abrir o olho)
- Dependendo da escolha, exibe diálogos específicos
- No final, vai para a conclusão do caminho azul (com texto diferente do padrão)

### Funções Auxiliares Principais

#### Gerenciamento de Textos de Contexto:
```gdscript
func is_description_text(text: String) -> bool:
    # Identifica textos que são instruções de contexto, não diálogo
    # Retorna true para textos com asteriscos ou palavras-chave específicas
```

#### Exibição de Texto Apropriada:
```gdscript
func show_appropriate_text(text: String) -> void:
    # Exibe o texto corretamente, tratando contextos diferentemente de diálogos
    # Textos de contexto não são mostrados e avançam automaticamente
```

#### Gerenciamento de Opções de Escolha:
```gdscript
func mark_option_as_incorrect(option_text: String, choices_array: Array, incorrect_array: Array) -> Array:
    # Marca uma opção como incorreta e a remove das opções disponíveis
    # Retorna a lista atualizada de escolhas
```

## Como Usar o Sistema de Escolhas em Diálogos

### Exemplo de Configuração de Escolhas:

```gdscript
# 1. Definir as opções de escolha
var options = ["Sim, vamos conversar", "Não, estou ocupado", "Talvez mais tarde"]

# 2. Obter referência ao sistema de escolhas de diálogo
@onready var choice_dialogue_box = $ChoiceDialogueBox

# 3. Mostrar as opções
choice_dialogue_box.show_choices(options, "Você gostaria de conversar?")

# 4. Conectar ao sinal de escolha
choice_dialogue_box.choice_selected.connect(_on_choice_made)

# 5. Função para processar a escolha
func _on_choice_made(choice_index: int) -> void:
    match choice_index:
        0: # Escolheu "Sim"
            dialogue_box.show_line("Ótimo! Sobre o que você gostaria de conversar?")
        1: # Escolheu "Não" 
            dialogue_box.show_line("Tudo bem. Até a próxima.")
        2: # Escolheu "Talvez"
            dialogue_box.show_line("Ok, me procure quando estiver disponível.")
```

### Exemplo de Diálogo com Caminhos Ramificados:

```gdscript
# Definir estados do diálogo
enum DialogueState { INTRO, BRANCH_A, BRANCH_B, CONCLUSION }

# Variáveis para controlar o fluxo
var current_state = DialogueState.INTRO
var current_text_index = 0

# Arrays de texto para cada caminho
var intro_texts = ["Olá viajante!", "Você parece perdido."]
var branch_a_texts = ["Vou te mostrar o caminho.", "Siga por esta trilha."]
var branch_b_texts = ["Boa sorte então!", "Cuidado com os perigos."]
var conclusion_texts = ["Até mais!"]

# Função para processar o próximo texto com base no estado
func process_next():
    match current_state:
        DialogueState.INTRO:
            if current_text_index < intro_texts.size():
                dialogue_box.show_line(intro_texts[current_text_index])
                current_text_index += 1
            else:
                # Mostrar escolhas ao final da introdução
                choice_dialogue_box.show_choices(
                    ["Preciso de ajuda", "Estou bem, obrigado"], 
                    "Como posso ajudar?"
                )
                
        DialogueState.BRANCH_A, DialogueState.BRANCH_B:
            var texts = branch_a_texts if current_state == DialogueState.BRANCH_A else branch_b_texts
            if current_text_index < texts.size():
                dialogue_box.show_line(texts[current_text_index])
                current_text_index += 1
            else:
                current_state = DialogueState.CONCLUSION
                current_text_index = 0
                process_next()
                
        DialogueState.CONCLUSION:
            if current_text_index < conclusion_texts.size():
                dialogue_box.show_line(conclusion_texts[current_text_index])
                current_text_index += 1
            else:
                finish_dialogue()

# Função para processar a escolha do jogador
func on_choice_made(choice_index):
    if choice_index == 0:  # "Preciso de ajuda"
        current_state = DialogueState.BRANCH_A
    else:  # "Estou bem, obrigado"
        current_state = DialogueState.BRANCH_B
    
    current_text_index = 0
    process_next()
```

## Próximas Melhorias Planejadas

- ✓ ~~Sistema de escolhas para diálogos interativos~~ (Implementado!)
- ✓ ~~Sistema de ramificação de diálogos~~ (Implementado!)
- ✓ ~~Sistema para processar instruções de contexto~~ (Implementado!)
- ✓ ~~Sistema de clique para avançar diálogos~~ (Implementado!)
- Suporte para exibir nome e avatar do personagem que está falando
- Efeitos de emoção no texto (tremer, ondular, cores diferentes)
- Sistema de salvamento do progresso do diálogo (base implementada)
- Internacionalização (i18n) para facilitar traduções

## Modo de Depuração

O sistema de diálogo inclui um modo de depuração que pode ser ativado para auxiliar no desenvolvimento:

```gdscript
const DEBUG_DIALOGUE = true  # Ative para logs detalhados
```

Quando ativado, o sistema registra:
- Transições entre estados de diálogo
- Texto exibido ou ignorado (no caso de contexto)
- Escolhas feitas pelo jogador
- Caminhos seguidos durante a conversa

Este modo é útil para identificar problemas no fluxo de diálogo durante o desenvolvimento.

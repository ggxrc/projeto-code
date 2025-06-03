# Sistema de Diálogos - Documentação

## Visão Geral
O sistema de diálogos do Projeto Code implementa uma forma flexível de exibir conversas e textos narrativos no jogo. O sistema utiliza efeitos de digitação para simular textos sendo escritos em tempo real e permite controle sobre o ritmo da narrativa.

## Componentes Principais

### DialogueBox (dialogue_box.gd)
Localização: `scenes/diálogos/DialogueBox.tscn` e `scenes/diálogos/dialogue_box.gd`

A caixa de diálogo principal que exibe textos de personagens e da narrativa.

#### Funcionalidades principais:
- **Efeito de Digitação**: Exibe o texto caractere por caractere com velocidade ajustável
- **Sinalização**: Emite sinais quando uma linha de diálogo é concluída
- **Controle de Visibilidade**: Métodos para exibir e ocultar a caixa de diálogo
- **Avanço de Texto**: Permite pular ou acelerar a exibição do texto atual

#### Métodos Importantes:
- `show_line(text_content: String, speed: float = 0.03)`: Exibe uma linha de texto com efeito de digitação
- `hide_box()`: Oculta a caixa de diálogo e reinicia seu estado
- `advance_or_skip_typewriter()`: Avança ou pula completamente o efeito de digitação

#### Sinais:
- `dialogue_line_finished`: Emitido quando uma linha de diálogo termina de ser exibida

### DescriptionBox (description_box.gd)
Localização: `scenes/diálogos/DescriptionBox.tscn` e `scenes/diálogos/description_box.gd`

Uma variante da caixa de diálogo utilizada para exibir descrições de objetos, áreas ou eventos no jogo.

## Integração com Outras Partes do Jogo

### No Prólogo
O sistema de diálogos é utilizado no prólogo (`prologue.gd`) para introduzir a história do jogo:

```gdscript
# Exemplo de como o sistema de diálogos é usado no prólogo
var linhas_dialogo: Array[String] = [
    "Seja bem vindo(a), vejo que você é novo por aqui.",
    "Você pode achar que o começo é fácil, mas você sabe o que fazer?"
]

func _exibir_linha_atual() -> void:
    if indice_linha_atual < linhas_dialogo.size():
        tela_inicial.exibir_linha(linhas_dialogo[indice_linha_atual])
```

## Como Usar o Sistema de Diálogos

### Exemplo de Uso Básico:

```gdscript
# 1. Obter referência ao sistema de diálogos
@onready var dialogue_box = $DialogueBox

# 2. Exibir uma linha de diálogo
dialogue_box.show_line("Olá, jogador! Bem-vindo ao mundo de Projeto Code.", 0.05)

# 3. Conectar ao sinal de conclusão do diálogo
dialogue_box.dialogue_line_finished.connect(_on_dialogue_finished)

# 4. Função chamada quando o diálogo termina
func _on_dialogue_finished() -> void:
    # Lógica para após o diálogo ser concluído
    print("Diálogo concluído!")
```

### Exemplo de Sequência de Diálogos:

```gdscript
var dialogos = [
    "Esta é a primeira linha do diálogo.",
    "Esta é a segunda linha do diálogo.",
    "Esta é a linha final do diálogo."
]
var indice_atual = 0

func iniciar_conversa() -> void:
    dialogue_box.dialogue_line_finished.connect(_proxima_linha)
    _exibir_proxima_linha()

func _exibir_proxima_linha() -> void:
    if indice_atual < dialogos.size():
        dialogue_box.show_line(dialogos[indice_atual])
        indice_atual += 1
    else:
        _finalizar_conversa()

func _finalizar_conversa() -> void:
    dialogue_box.dialogue_line_finished.disconnect(_proxima_linha)
    dialogue_box.hide_box()
    # Continuar com o jogo
```

## Personalização

Para personalizar a aparência da caixa de diálogo:
1. Abra a cena `DialogueBox.tscn` no editor Godot
2. Ajuste as propriedades visuais do nó `BackgroundBox`
3. Modifique a fonte e estilo do texto no nó `TextLabel`

## Melhores Práticas

- Mantenha os textos de diálogo em arrays ou recursos separados para facilitar edição e tradução
- Use velocidades diferentes de digitação para transmitir emoções diferentes
- Implemente um sistema para pular diálogos para jogadores que já viram o texto
- Considere adicionar efeitos de som para a digitação do texto

## Limitações Atuais

- O sistema atual não suporta ramificações complexas de diálogos
- Não há suporte nativo para escolhas do jogador durante diálogos
- O sistema de fonte não suporta estilos diferentes em uma mesma caixa

## Futuras Melhorias Planejadas

- Sistema de escolhas para diálogos interativos
- Suporte para exibir nome e avatar do personagem que está falando
- Efeitos de emoção no texto (tremer, ondular, cores diferentes)
- Sistema de salvamento do progresso do diálogo

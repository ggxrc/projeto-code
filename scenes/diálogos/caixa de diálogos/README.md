# Caixa de Diálogo Estilizada

Esta é uma implementação de caixa de diálogo estilizada usando imagens para o projeto.

## Instruções de Uso

1. Adicione a cena `DialogueBox.tscn` como filho da sua cena principal.
2. Acesse a caixa de diálogo através de script:

```gdscript
@onready var dialogue_box = $DialogueBoxUI

# Para mostrar uma linha de diálogo
dialogue_box.show_line("Seu texto aqui", 0.05) # O segundo parâmetro é a velocidade de digitação

# Para personalizar a aparência
dialogue_box.set_dialogue_style(
    "res://caminho/para/sua/imagem.png", # Caminho da textura (deixe em branco para usar a padrão)
    Color(1.0, 1.0, 1.0), # Cor do texto
    32, # Tamanho da fonte
    Color(1.0, 1.0, 1.0, 1.0) # Cor/opacidade da imagem de fundo
)

# Para esconder a caixa de diálogo
dialogue_box.hide_box()
```

## Personalização da Imagem de Fundo

Para personalizar a imagem de fundo da caixa de diálogo:

1. Crie uma imagem no formato PNG com as dimensões desejadas (recomendado: 1280x180)
2. Coloque a imagem em `assets/UI/dialogue_box/`
3. No seu script, carregue a imagem usando `dialogue_box.set_dialogue_style("res://assets/UI/dialogue_box/sua_imagem.png")`

Você pode ver um exemplo de uso na cena `DialogueExample.tscn` em `scenes/testes/dialogue_example/`

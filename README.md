# Projeto Code - Documentação

## Visão Geral
Projeto Code é um jogo desenvolvido com a engine Godot 4.4, apresentando uma experiência de jogo com diálogos narrativos, menus interativos e sistemas de controle para PC e dispositivos móveis.

## Estrutura do Projeto

### Organização de Arquivos

```
projeto-code/
├── assets/                    # Recursos visuais e de áudio
│   ├── character sprites/     # Sprites dos personagens
│   ├── fonts/                 # Fontes utilizadas no jogo
│   ├── interface/             # Elementos de interface do usuário
│   └── textures/              # Texturas de ambientes e objetos
├── bregueça/                  # Pasta com recursos de testes ou legados
├── scenes/                    # Cenas do jogo organizadas por função
│   ├── actors/                # Personagens jogáveis e NPCs
│   ├── configurações/         # Menu de configurações do jogo
│   ├── diálogos/              # Sistema de diálogos
│   ├── global/                # Sistemas globais e efeitos
│   ├── main menu/             # Menu principal do jogo
│   ├── menu pausa/            # Menu de pausa durante o jogo
│   ├── orquestrador/          # Sistema de gerenciamento de cenas
│   ├── prologue/              # Cena de prólogo/introdução
│   └── testes/                # Cenas para testes de desenvolvimento
└── scripts/                   # Scripts genéricos utilizados em várias partes
```

## Componentes Principais

### Sistema de Gerenciamento de Cenas (Orquestrador)

O sistema de gerenciamento de cenas é implementado principalmente por dois scripts:

1. `game.gd` - Gerenciador principal que controla os estados do jogo e as transições entre as cenas.
2. `Orquestrador.gd` - Sistema de compatibilidade que oferece suporte para estrutura de código legada.

O jogo utiliza um sistema de estados para controlar o fluxo do jogo:
- MENU - Menu principal
- PROLOGUE - Sequência introdutória
- PLAYING - Jogabilidade principal
- PAUSED - Jogo pausado
- OPTIONS - Menu de opções
- CONFIG_FROM_PAUSE - Configurações acessadas pelo menu de pausa

### Sistema de Diálogos

O jogo implementa um sistema de diálogos para narrativa, com os seguintes componentes:

1. `dialogue_box.gd` - Exibe caixas de diálogo com efeito de digitação.
2. `description_box.gd` - Fornece descrições de elementos do jogo.

Características principais do sistema de diálogos:
- Efeito de digitação ajustável
- Sinalização quando diálogos são concluídos
- Possibilidade de pular ou avançar diálogos

### Sistema de Controle do Jogador

O controle do jogador é implementado em dois scripts principais:

1. `player.gd` - Implementação básica de movimento com suporte a controles de teclado.
2. `touch_screen_joystick.gd` - Implementação complexa de joystick virtual para dispositivos com tela sensível ao toque.

O joystick virtual tem as seguintes características:
- Responde a entrada de toque
- Modos fixo e dinâmico
- Personalização visual (texturas, cores)
- Zona morta e suavização de reset

### Prólogo e Introdução

O sistema de prólogo (`prologue.gd`) implementa:
- Sequência de diálogos introdutórios
- Sistema para pular introdução em jogadas subsequentes
- Transição para o gameplay após conclusão

## Fluxo do Jogo

1. O jogo inicia no Menu Principal.
2. O jogador pode iniciar um novo jogo, acessar opções ou sair.
3. Ao iniciar um novo jogo, é apresentado o Prólogo com diálogos introdutórios.
4. Após o prólogo, o jogo transita para o modo de jogabilidade principal.
5. Durante o jogo, o jogador pode pausar para acessar opções ou voltar ao menu principal.

## Recursos Visuais

O jogo utiliza diversos recursos visuais:
- Sprites de personagens (234x350 pixels)
- Texturas de interior e exterior para os ambientes
- Interface com botões e ícones personalizados
- Fontes especiais (Daydream, Pixellari)

## Configuração do Projeto

O jogo é configurado para:
- Resolução base de 1280x720 pixels
- Modo de janela personalizável
- Orientação específica para dispositivos móveis

## Controles

O jogo suporta:
- Controles de teclado para PC (setas direcionais)
- Joystick virtual para dispositivos móveis
- Tecla Esc para pausar o jogo

## Requisitos de Sistema

- Godot Engine 4.4 ou superior
- Suporte a OpenGL
- Compatível com PC e dispositivos móveis

## Desenvolvimento

### Para Desenvolvedores

Para contribuir com o desenvolvimento:

1. Clone o repositório
2. Abra o projeto no Godot Engine 4.4+
3. A cena principal do jogo está em `scenes/orquestrador/Game.tscn`
4. O fluxo do jogo é gerenciado pelo script `scenes/orquestrador/game.gd`

### Convenções de Código

O projeto utiliza:
- Nomenclatura em camelCase para variáveis e funções
- PascalCase para nomes de classes e cenas
- Organização de arquivos por funcionalidade
- Documentação em comentários para funções complexas

## Licença

Este projeto está sob a licença incluída no arquivo LICENSE.md na raiz do projeto.

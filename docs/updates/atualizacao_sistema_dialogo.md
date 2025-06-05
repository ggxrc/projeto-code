# Atualização do Sistema de Diálogo - Prólogo

## Visão Geral das Alterações

O sistema de diálogo do prólogo foi melhorado significativamente para adicionar:

1. **Sistema de ramificação de diálogos** - Caminhos amarelo e azul com diferentes textos e conclusões
2. **Mecanismo de escolhas interativas** - Opções que afetam o curso do diálogo
3. **Tratamento de textos de contexto** - Textos com asteriscos (*) são tratados como instruções de contexto
4. **Sistema de feedback de escolhas** - Opções incorretas são removidas após tentativas

## Detalhes Técnicos Implementados

### 1. Máquina de Estados do Diálogo

Implementamos uma máquina de estados completa para gerenciar o fluxo de diálogo:

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

### 2. Sistema de Caminhos Narrativos

Dois caminhos principais foram implementados:
- **Caminho Amarelo (Padrão)**: Segue o fluxo padrão com as opções "levantar" e "abrir o olho"
- **Caminho Azul (Alternativo)**: Fluxo alternativo alcançado ao escolher "sair da cama"

### 3. Sistema de Escolhas Interativas

As escolhas são gerenciadas de forma dinâmica:
- Opções incorretas são removidas das escolhas disponíveis
- O jogador recebe feedback imediato sobre suas escolhas
- As escolhas afetam diretamente o caminho narrativo seguido

### 4. Gerenciamento de Textos de Contexto

Textos marcados com asteriscos são tratados como instruções narrativas:
- Não são exibidos como diálogos para o jogador
- O sistema avança automaticamente ao encontrar esses textos
- Identificação baseada em padrões de texto e palavras-chave

### 5. Indicador Visual de Clique

Um indicador visual foi implementado para mostrar quando o jogador precisa interagir:
- Animação de pulsação para destacar a necessidade de clique
- Suporte para mouse, toque e entrada de teclado (espaço/enter)
- Feedback visual para melhorar a experiência do usuário

### 6. Sistema de Depuração

Um sistema de logs detalhados foi implementado para auxiliar no desenvolvimento:
- Rastreamento de estados e transições
- Monitoramento de escolhas e caminhos seguidos
- Informações sobre textos exibidos ou ignorados

## Funcionamento dos Caminhos do Diálogo

### Fluxo do Diálogo

1. **Introdução**:
   - Apresentação da cena inicial do protagonista dormindo

2. **Primeira Escolha** - "O que você vai fazer?":
   - *Opção correta*: "acordar" - Avança para a segunda escolha
   - *Opções incorretas*: "levantar", "abrir o olho", "sair da cama" - São removidas após tentativas

3. **Segunda Escolha** - "Agora que ele está acordado, o que vem depois?":
   - *Opções para caminho amarelo*: "levantar" ou "abrir o olho" 
   - *Opção para caminho azul*: "sair da cama"
   - *Opções incorretas*: São removidas se gerarem feedback negativo

4. **Caminhos Narrativos**:
   - **Caminho Amarelo**: Execução normal das ações restantes (levantar/abrir o olho)
   - **Caminho Azul**: O protagonista cai da cama, seguido de novas escolhas

5. **Conclusão**:
   - Texto específico para cada caminho, explicando o conceito de algoritmo

## Uso do Modo de Depuração

Para ativar/desativar o modo de depuração, modifique:

```gdscript
// No topo do arquivo prologue.gd
const DEBUG_DIALOGUE = true  // true para ativar, false para desativar
```

## Documentação Completa

A documentação completa do sistema de diálogos foi atualizada e está disponível em:
- `docs/sistema_dialogos.md`

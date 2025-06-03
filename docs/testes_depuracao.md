# Testes e Depuração - Documentação

## Visão Geral

O Projeto Code possui um sistema de testes e ferramentas de depuração para facilitar o desenvolvimento, detecção de problemas e garantia da qualidade do código. Esta documentação cobre as metodologias e ferramentas disponíveis para testar e depurar o jogo.

## Cena de Depuração

Localização: `scenes/testes/DebugScene.tscn` e `scenes/testes/debug_scene.gd`

A cena de depuração é um ambiente isolado onde os desenvolvedores podem testar componentes e sistemas específicos sem interferência do fluxo normal do jogo.

### Recursos da Cena de Depuração

- Controles simplificados para teste de personagem
- Console de saída para visualização de variáveis e estados
- Ferramentas para testar sistemas específicos (diálogo, transições, etc.)
- Ambiente controlado para reprodução de bugs

### Como Usar a Cena de Depuração

1. Abra a cena `scenes/testes/DebugScene.tscn` no editor Godot
2. Execute a cena com F6 (ao invés do jogo completo)
3. Use os controles de depuração disponíveis na cena
4. Verifique a saída no console de depuração

```gdscript
# Exemplo de uso do debug_scene.gd para testar funcionalidade
func _on_test_dialogue_button_pressed():
    var dialogue_system = $DialogueSystem
    dialogue_system.show_line("Isto é um teste de diálogo para depuração!")
    _log_debug("Teste de diálogo iniciado")

func _log_debug(message: String):
    print("DEBUG: " + message)
    $DebugConsole.text += "\n" + message
```

## Mensagens de Depuração

O projeto utiliza três níveis principais de mensagens de depuração:

1. **print()** - Informação básica
2. **printerr()** - Erros e avisos importantes
3. **push_error()** - Erros críticos que precisam ser registrados

### Melhores Práticas para Mensagens de Depuração

- Use mensagens claras que identifiquem o arquivo e método
- Inclua valores de variáveis relevantes
- Adicione prefixos para facilitar a filtragem (ex: "DIÁLOGO:", "JOGADOR:")

```gdscript
# Exemplo de boas mensagens de depuração
func _process_interaction():
    if not is_instance_valid(target_npc):
        printerr("Interaction.gd: Alvo de interação inválido!")
        return
        
    print("INTERAÇÃO: Iniciando diálogo com " + target_npc.name)
```

## Ferramentas de Depuração Integradas

### Console de Depuração Godot

O console de depuração da Godot Engine pode ser aberto durante a execução do jogo para visualizar:
- Mensagens impressas com print() e printerr()
- Erros e avisos do sistema
- Rastreamento de pilha para exceções

### Monitor de Desempenho

Para monitorar o desempenho do jogo:
1. Vá para "Debug → Monitor" no editor Godot
2. Observe métricas como FPS, memória e tempo de processamento
3. Identifique gargalos de desempenho em diferentes sistemas

## Testes Automatizados

O projeto ainda não implementa testes automatizados completos, mas recomenda-se adicionar:

### Testes de Unidade (Recomendado)
- Testar funções isoladas de lógica crítica
- Validar o comportamento dos sistemas principais
- Garantir que alterações não quebrem funcionalidades existentes

### Testes de Integração (Recomendado)
- Testar a interação entre diferentes sistemas
- Validar fluxos de jogo completos
- Testar transições entre cenas e estados

## Tratamento de Erros

O projeto implementa tratamento básico de erros em vários sistemas:

```gdscript
# Exemplo de tratamento de erro no sistema de diálogos
func show_line(text_content: String, speed: float = 0.03) -> void:
    if not is_instance_valid(text_label) or not is_instance_valid(background_box):
        printerr("DialogueBox: Nó TextLabel ou BackgroundBox não encontrado!")
        return
        
    # Resto da função continua normalmente se não houver erro
```

## Ferramentas para Depuração Visual

### Visualização de Colisões
Para depurar colisões e áreas de física:
1. No menu do editor vá para "Debug → Visible Collision Shapes"
2. As formas de colisão serão visíveis durante a execução do jogo

### Visualização de Navegação
Para depurar sistemas de navegação:
1. No menu do editor vá para "Debug → Visible Navigation"
2. Mapas de navegação e caminhos serão visíveis

## Guia de Resolução de Problemas Comuns

### Personagem não se Move
- Verifique se o script de controle está conectado
- Confirme que o nó CharacterBody2D está configurado corretamente
- Verifique se não há colisões bloqueando o movimento

### Diálogos não Aparecem
- Verifique se o sistema de diálogos está instanciado corretamente
- Confirme que o texto não está vazio
- Verifique se a caixa de diálogo está visível e em camada correta

### Problemas de Desempenho
- Use o Monitor de Desempenho para identificar gargalos
- Verifique se há loops infinitos ou recursão excessiva
- Reduza a complexidade de cenas com muitos nós

## Ambientes de Teste

### Dispositivos Móveis
Para testar em dispositivos móveis:
1. Configure o dispositivo para depuração USB
2. Use o Godot Remote Debugger para conectar ao dispositivo
3. Execute o jogo diretamente no dispositivo para testar controles de toque

### Diferentes Resoluções
Para testar em diferentes resoluções:
1. Use o recurso "Editor → Editor Settings → Debug → Window Size → Test Width/Height"
2. Teste com múltiplas resoluções para garantir responsividade

## Plano de Melhoria para Testes

1. **Implementar Framework de Testes**
   - Adicionar GUT (Godot Unit Test) ou framework similar
   - Criar testes para sistemas críticos

2. **CI/CD**
   - Configurar integração contínua para executar testes automaticamente
   - Garantir que novos PRs passem por testes automatizados

3. **Monitoramento de Crashes**
   - Implementar sistema de registro de erros
   - Coletar relatórios de falhas dos usuários

## Conclusão

Um bom sistema de testes e depuração é essencial para o desenvolvimento contínuo do Projeto Code. Ao seguir as práticas descritas neste documento, os desenvolvedores podem identificar e resolver problemas mais rapidamente, garantindo uma experiência de jogo estável e agradável para os usuários finais.

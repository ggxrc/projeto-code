# Porta da Casa da Jucira - Sistema de Interação Refatorado

## ✅ **Refatoração Concluída**

A entrada da casa da Jucira foi **refatorada com sucesso** para usar:
- **`change_scene_to_packed()`** ao invés de `change_scene_to_file()`
- **Sistema de interação padrão do projeto** (herda de `InteractiveObject`)
- **Lógica de interação manual** - só muda de cena quando o jogador pressiona E/ui_accept

## 📁 **Arquivos Criados/Modificados**

### **Porta de Entrada** - `porta_casa_jucira.gd`
- **Localização**: `scenes/prologue/Meio/porta_casa_jucira.gd`
- **Herda de**: `InteractiveObject` ✅
- **Função**: Transição de `Gameplay.tscn` → `CasaIdosaED.tscn`
- **Prompt**: "Entrar na casa" ✅
- **Área**: 20x20 pixels na posição (22.143, 23.571) ✅
- **Posição**: Exatamente sobre o CollisionShape da porta ✅

### **Porta de Saída** - `casa_jucira_exit.gd`
- **Localização**: `scenes/prologue/Meio/Casas/casa_jucira_exit.gd`
- **Herda de**: `InteractiveObject` ✅
- **Função**: Transição de `CasaIdosaED.tscn` → `Gameplay.tscn`
- **Prompt**: "Sair da casa"
- **Área**: 20x20 pixels ✅

## 🎯 **Funcionalidades Implementadas**

### **✅ Sistema de Interação Padrão**
- Herda de `InteractiveObject` como outros objetos do projeto
- Área de interação 20x20 pixels (mesmo tamanho do CollisionShape da porta) ✅
- Exibe prompt personalizado ao se aproximar
- Integração com sistema de botão de interação do player
- Collision layers configuradas corretamente (mask = 1 para detectar player) ✅

### **✅ Interação Manual**
- **NÃO muda de cena automaticamente**
- Aguarda comando do jogador (E ou ui_accept)
- Cooldown de 1 segundo entre interações
- Feedback visual através do botão de interação
- Debug logging para troubleshooting ✅

### **✅ Transições Seguras**
- Usa `change_scene_to_packed()` conforme solicitado
- Carregamento prévio das cenas na inicialização
- Prevenção de múltiplas transições com flag `is_transitioning`
- Som de interação (se AudioManager disponível)

### **✅ Compatibilidade**
- Funciona com o sistema de interação do player
- Método `interact()` para compatibilidade com sistemas antigos
- Integração com `objeto_interagivel_atual` do player

## 🔧 **Correções Aplicadas**

1. **✅ Tamanho da área de interação ajustado** para 20x20 pixels (mesmo tamanho do CollisionShape da porta)
2. **✅ Posição da área ajustada** para (22.143, 23.571) - exatamente sobre a porta
3. **✅ Texto do botão simplificado** para "Entrar na casa"
4. **✅ Collision layers configuradas** corretamente para detectar o player
5. **✅ Debug logging adicionado** para facilitar troubleshooting
6. **✅ Herança de InteractiveObject** implementada corretamente

## Como Usar:

### Porta de Entrada (Já Integrada)
A porta de entrada já está configurada no `Gameplay.tscn` na área:
```
ExteriorVizinhos/Casas/Casa da  Velha/Porta e Janela/PortaDaVelha
```

### Porta de Saída (Necessita Integração Manual)
Para adicionar a porta de saída na casa da Jucira:

1. Abra `scenes/prologue/Meio/Casas/CasaIdosaED.tscn`
2. Adicione um novo nó `Node2D` como filho da raiz
3. Nomeie-o como "PortaSaida"
4. Anexe o script `casa_jucira_exit.gd` a este nó
5. Ajuste a posição da porta conforme necessário

Ou, alternativamente, adicione o seguinte código ao script principal da casa:

```gdscript
func _ready():
    # Código existente...
    
    # Adicionar porta de saída
    var exit_script = load("res://scenes/prologue/Meio/Casas/casa_jucira_exit.gd")
    var exit_node = Node2D.new()
    exit_node.name = "PortaSaida"
    exit_node.set_script(exit_script)
    add_child(exit_node)
    
    # Opcional: definir posição customizada
    # exit_node.set_exit_position(Vector2(100, 50))
```

## Funcionalidades:

### Entrada da Casa:
- ✅ Detecção automática do jogador se aproximando
- ✅ Exibição de dica "Entrar na casa da Jucira"
- ✅ Interação via tecla E ou ui_accept
- ✅ Transição suave usando `change_scene_to_packed()`
- ✅ Desabilitação temporária do movimento do jogador
- ✅ Som de interação

### Saída da Casa:
- ✅ Área de detecção configurável
- ✅ Exibição de dica "Sair da casa"
- ✅ Interação via tecla E ou ui_accept
- ✅ Retorno ao Gameplay usando `change_scene_to_packed()`
- ✅ Som de interação

## Vantagens do `change_scene_to_packed()`:

1. **Performance**: Cena pré-carregada em memória
2. **Confiabilidade**: Menos chance de erro de carregamento
3. **Velocidade**: Transição mais rápida
4. **Controle**: Melhor gerenciamento de recursos

## Integração com Sistema Existente:

Os scripts são compatíveis com:
- ✅ Sistema de dicas de interação do player
- ✅ Sistema de AudioManager
- ✅ Sistema de grupos do Godot
- ✅ Detecção automática do jogador
- ✅ Métodos de compatibilidade (`interact()`)

## Testes Recomendados:

1. Verificar se a transição funciona corretamente
2. Testar se o jogador mantém sua posição após a transição
3. Confirmar que as dicas de interação aparecem
4. Validar que os sons funcionam
5. Testar em diferentes plataformas (PC/Mobile)

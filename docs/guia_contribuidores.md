# Guia para Contribuidores - Projeto Code

## Introdução

Obrigado por considerar contribuir para o Projeto Code! Este documento fornece diretrizes e informações importantes para colaboradores que desejam participar do desenvolvimento do projeto. Seguir estas orientações ajudará a manter a qualidade e consistência do código.

## Começando

### Preparação do Ambiente

1. **Requisitos**:
   - Godot Engine 4.4 ou superior
   - Git para controle de versão
   - Editor de código com suporte a GDScript (recomendado: VS Code com extensão Godot Tools)

2. **Configuração Inicial**:
   ```powershell
   # Clone o repositório
   git clone https://github.com/seu-usuario/projeto-code.git
   
   # Entre no diretório do projeto
   cd projeto-code
   
   # Configure seu usuário Git (se ainda não configurado)
   git config user.name "Seu Nome"
   git config user.email "seu.email@exemplo.com"
   ```

3. **Abra o Projeto**:
   - Inicie a Godot Engine
   - Selecione "Import" e navegue até a pasta do projeto
   - Selecione o arquivo `project.godot`

### Fluxo de Trabalho de Desenvolvimento

1. **Crie uma Branch**:
   ```powershell
   # Certifique-se de estar na branch principal atualizada
   git checkout main
   git pull
   
   # Crie uma nova branch para sua feature/correção
   git checkout -b feature/nome-da-feature
   # ou
   git checkout -b fix/nome-do-bug
   ```

2. **Implemente suas Alterações**:
   - Siga as convenções de código descritas neste documento
   - Mantenha o escopo de suas alterações focado na feature/correção específica
   - Adicione comentários explicativos em partes complexas do código

3. **Teste suas Alterações**:
   - Teste extensivamente usando a cena de depuração
   - Verifique se não introduziu novos bugs ou regressões
   - Teste em diferentes resoluções se relevante

4. **Commit e Push**:
   ```powershell
   # Adicione seus arquivos modificados
   git add .
   
   # Commit com mensagem descritiva
   git commit -m "Tipo: Descrição concisa da alteração"
   
   # Push para o repositório remoto
   git push origin feature/nome-da-feature
   ```

5. **Crie um Pull Request (PR)**:
   - Vá para o repositório no GitHub
   - Clique em "New pull request"
   - Selecione sua branch e a branch principal como destino
   - Forneça uma descrição detalhada das alterações
   - Solicite revisão de outros desenvolvedores

## Convenções de Código

### Estilo de Código

#### Nomenclatura

- **Variáveis e Funções**: Use `camelCase`
  ```gdscript
  var playerSpeed = 200
  func calculateDamage():
      pass
  ```

- **Classes e Cenas**: Use `PascalCase`
  ```gdscript
  class_name PlayerController
  # Arquivos de cena: PlayerScene.tscn
  ```

- **Constantes e Enums**: Use `SNAKE_CASE_MAIÚSCULO`
  ```gdscript
  const MAX_HEALTH = 100
  enum PLAYER_STATE { IDLE, WALKING, RUNNING }
  ```

#### Indentação e Formatação

- Use **espaços** para indentação (4 espaços por nível)
- Limite linhas a **80-100 caracteres** quando possível
- Separe funções com uma linha em branco
- Agrupe códigos relacionados e adicione comentários para separar seções

```gdscript
# Exemplo de formatação adequada
func calculate_damage(base_damage: float, critical: bool) -> float:
    var total_damage = base_damage
    
    if critical:
        total_damage *= 2.0
    
    return total_damage

# Sistema de inventário
func add_item(item_id: String, quantity: int = 1) -> bool:
    if inventory.has(item_id):
        inventory[item_id] += quantity
    else:
        inventory[item_id] = quantity
    
    return true
```

### Comentários

- Use comentários para explicar **por que** algo está sendo feito, não **o que** está sendo feito
- Documente parâmetros e valores de retorno em funções complexas
- Use comentários de seção para organizar arquivos grandes

```gdscript
# Correto: Explica o motivo
# Reduzimos a velocidade enquanto o jogador está na água
speed *= 0.5

# Incorreto: Apenas descreve o código
# Multiplica a velocidade por 0.5
speed *= 0.5

# Documentação de função
## Calcula o dano com base em múltiplos fatores
## Parâmetros:
## - base_damage: Dano base do ataque
## - critical: Se é um golpe crítico
## - defense: Valor de defesa do alvo
## Retorna o dano final após cálculos
func calculate_final_damage(base_damage: float, critical: bool, defense: float) -> float:
```

### Organização de Arquivos

- Mantenha arquivos relacionados em diretórios apropriados
- Nomeie cenas e scripts de forma consistente e descritiva
- Separe recursos visuais e lógica sempre que possível

## Práticas Recomendadas

### Para GDScript

- Use **tipos estáticos** quando possível para melhorar a detecção de erros
  ```gdscript
  func deal_damage(amount: int, target: Character) -> void:
  ```
  
- Prefira sinais para comunicação entre nós em vez de referências diretas
  ```gdscript
  # Emita um sinal em vez de chamar uma função diretamente
  signal player_damaged(amount)
  
  # Em algum lugar do código:
  emit_signal("player_damaged", 10)
  ```

- Use `onready` para referências a nós para evitar erros de inicialização
  ```gdscript
  @onready var animation_player = $AnimationPlayer
  ```

### Para Design de Cenas

- Mantenha cenas modularizadas e reutilizáveis
- Use cenas aninhadas para componentes complexos
- Evite nós profundamente aninhados quando possível
- Nomeie os nós de forma clara e descritiva

### Para Interface do Usuário

- Use containers (VBoxContainer, HBoxContainer) para layouts responsivos
- Mantenha a consistência visual em todos os menus
- Teste em diferentes resoluções de tela

## Diretrizes para Commits

- Escreva mensagens de commit claras e descritivas
- Use prefixos para indicar o tipo de alteração:
  - `feat:` Nova funcionalidade
  - `fix:` Correção de bug
  - `docs:` Documentação apenas
  - `style:` Formatação, sem alteração de código
  - `refactor:` Refatoração de código existente
  - `perf:` Melhorias de desempenho
  - `test:` Adição/correção de testes

Exemplos:
```
feat: Adiciona sistema de inventário
fix: Corrige colisão do personagem com paredes
docs: Atualiza documentação do sistema de diálogos
refactor: Otimiza sistema de carregamento de cenas
```

## Processo de Revisão de Código

Os pull requests seguirão este processo de revisão:

1. **Verificação Inicial**: O código segue as convenções e práticas do projeto?
2. **Funcionalidade**: A alteração funciona conforme esperado?
3. **Desempenho**: A alteração impacta negativamente o desempenho?
4. **Manutenibilidade**: O código é claro e fácil de manter?
5. **Testes**: As alterações foram adequadamente testadas?

## Reportando Bugs

Ao reportar bugs, inclua:

- Descrição detalhada do problema
- Passos para reproduzir
- Comportamento esperado vs. comportamento observado
- Capturas de tela ou vídeos (se aplicável)
- Informações sobre seu ambiente (OS, versão da Godot)

## Solicitando Funcionalidades

Para solicitar novas funcionalidades:

- Descreva claramente o que você gostaria de ver implementado
- Explique por que essa funcionalidade seria benéfica para o projeto
- Forneça exemplos ou mockups, se possível
- Considere como a funcionalidade se integraria aos sistemas existentes

## Licença e Atribuições

- Ao contribuir, você concorda que seu código será licenciado sob a mesma licença do projeto
- Certifique-se de ter os direitos necessários sobre qualquer conteúdo que contribuir
- Atribua corretamente recursos de terceiros (como assets, código, etc.)

## Recursos Adicionais

- [Documentação da Godot](https://docs.godotengine.org/)
- [Boas Práticas de GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Convenções de Git](https://www.conventionalcommits.org/)

---

Agradecemos sua contribuição para o Projeto Code! Seguindo estas diretrizes, podemos manter um projeto organizado e de alta qualidade.

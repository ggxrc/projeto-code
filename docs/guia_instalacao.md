# Guia de Instalação e Configuração - Projeto Code

## Requisitos do Sistema

### Para Desenvolvimento
- **Godot Engine**: Versão 4.4 ou superior
- **Sistema Operacional**: Windows, macOS ou Linux
- **Hardware Mínimo**:
  - Processador: Dual-core de 2 GHz ou superior
  - Memória: 4 GB RAM
  - GPU: Com suporte a OpenGL 3.3 ou superior
  - Armazenamento: 500 MB disponíveis

### Para Jogadores
- **Sistema Operacional**: Windows, macOS, Linux, Android ou iOS
- **Hardware Mínimo**:
  - Processador: Dual-core de 1.5 GHz ou superior
  - Memória: 2 GB RAM
  - GPU: Com suporte a OpenGL 3.3 ou superior (PC) ou OpenGL ES 3.0 (Mobile)
  - Armazenamento: 200 MB disponíveis

## Instalação para Desenvolvimento

### Passos para Configuração do Ambiente

1. **Instalar a Godot Engine**:
   - Baixe a Godot Engine 4.4 (ou versão mais recente) do [site oficial](https://godotengine.org/download)
   - Escolha a versão Standard (não a Mono/C#, a menos que pretenda usar recursos .NET)
   - Execute o arquivo baixado (não requer instalação)

2. **Obter o Código-Fonte**:
   - Clone o repositório usando Git:
     ```
     git clone https://github.com/seu-usuario/projeto-code.git
     ```
   - Ou baixe como arquivo ZIP e extraia em sua pasta de projetos

3. **Abrir o Projeto**:
   - Inicie a Godot Engine
   - Clique em "Import" (Importar) na tela inicial
   - Navegue até a pasta onde você clonou/extraiu o projeto
   - Selecione o arquivo `project.godot`
   - Clique em "Open" (Abrir)

4. **Verificar Dependências**:
   - Todos os recursos necessários estão incluídos no repositório
   - Não são necessárias dependências externas para execução básica

### Configuração do Projeto

1. **Configurações do Editor**:
   - Em Godot, vá para "Editor → Editor Settings" (Configurações do Editor)
   - Recomenda-se ativar "Auto Reload Changed Scripts" (Recarregar Scripts Automaticamente)
   - Em dispositivos de alta resolução, ajuste a escala da interface em "Interface → Display Scale"

2. **Configurações de Exportação**:
   - O projeto já inclui um arquivo `export_presets.cfg` com configurações básicas
   - Para personalizar, vá para "Project → Export" (Exportar)
   - Você pode ajustar configurações por plataforma-alvo (Windows, Android, etc.)

## Execução do Projeto

### Modo de Desenvolvimento

1. **Executar o Projeto**:
   - Com o projeto aberto na Godot Engine, clique no botão "Play" no canto superior direito
   - Alternativamente, pressione F5
   - O jogo será iniciado com a cena principal definida (Menu Principal)

2. **Depuração**:
   - Use o botão de "Depuração" (ícone de inseto) ao invés de "Play" para ativar ferramentas de depuração
   - A cena de debug pode ser acessada em `scenes/testes/DebugScene.tscn`

3. **Alternar entre Cenas**:
   - Durante o desenvolvimento, você pode querer testar cenas específicas
   - Para isso, abra a cena desejada (por exemplo, `scenes/actors/player.tscn`) 
   - Clique em "Play Scene" (F6) para executar apenas essa cena

### Exportar o Jogo

Para criar uma versão executável do jogo:

1. **Configurar Exportação**:
   - Vá para "Project → Export" (Projeto → Exportar)
   - Selecione a plataforma desejada (Windows, Android, etc.)
   - Configure as opções específicas da plataforma

2. **Exportar o Projeto**:
   - Clique em "Export Project" (Exportar Projeto)
   - Escolha o local de destino e nome do arquivo
   - Aguarde a conclusão da exportação

3. **Testar o Executável**:
   - Navegue até a pasta onde você exportou o projeto
   - Execute o arquivo gerado para verificar se funciona corretamente
   - Verifique se os recursos (imagens, sons, etc.) foram incluídos corretamente

## Configurações Específicas por Plataforma

### Para Windows:
- O executável gerado (.exe) pode ser distribuído com seus arquivos de recursos
- Considere usar um instalador como Inno Setup para distribuição mais profissional

### Para Android:
- Você precisará configurar o SDK do Android nas preferências do editor
- Gerar um keystore para assinatura do APK (obrigatório para Google Play)
- Ajustar permissões no arquivo de exportação

### Para Web:
- O jogo pode ser exportado como HTML5 para execução em navegadores
- Alguns recursos podem precisar de ajustes para compatibilidade com WebGL

## Solução de Problemas Comuns

### Recursos Não Encontrados
- Verifique se todos os caminhos de arquivo usam `res://` ao invés de caminhos absolutos
- Confirme que todos os recursos estão na pasta correta

### Problemas de Performance
- Para dispositivos móveis, reduza a resolução e efeitos visuais
- Verifique por vazamentos de memória em cenas persistentes

### Erros de Script
- Use o Debugger da Godot para identificar a origem dos erros
- Verifique o console para mensagens de erro específicas

## Contribuindo com o Desenvolvimento

Para contribuir com o projeto:

1. Crie um fork do repositório
2. Implemente suas alterações em um branch separado
3. Siga as convenções de código estabelecidas (camelCase para variáveis, PascalCase para classes)
4. Envie um Pull Request com uma descrição clara das alterações

## Recursos Adicionais

- [Documentação da Godot](https://docs.godotengine.org/)
- [Tutorial de GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [Comunidade da Godot no Discord](https://discord.gg/4JBkykG)

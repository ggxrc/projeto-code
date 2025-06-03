# Recursos Artísticos e Visuais - Documentação

## Visão Geral
O Projeto Code utiliza uma variedade de recursos artísticos e visuais para criar sua estética única. Esta documentação detalha os elementos visuais do jogo, incluindo sprites, texturas, fontes e elementos de interface do usuário.

## Sprites de Personagens

### Personagem Principal
Localização: `assets/character sprites/Sprite Prota.png`

- Formato: PNG
- Dimensões: Baseado em uma folha de sprites personalizada
- Estilo: Pixel art detalhado
- Ferramenta de edição: Arquivo fonte disponível (.ase) para Aseprite

### Personagem Secundário
Localização: `assets/character sprites/personagem-sprite-sheet-jogoveio-234x350.png`

- Formato: PNG
- Dimensões: 234x350 pixels
- Estilo: Pixel art
- Organização: Folha de sprites com múltiplos frames para animação

### Personagem Idosa
Localização: `assets/character sprites/Sprite VelhaED.ase`

- Formato: Arquivo fonte do Aseprite
- Estilo: Pixel art
- Uso: Personagem não jogável (NPC)

## Texturas de Ambiente

### Ambientes Exteriores
Localização: `assets/textures/sprites exterior/`

Principais arquivos:
- `CityBuilder.png` - Conjunto de tiles para construção de cidades/ambientes urbanos

### Ambientes Interiores
Localização: `assets/textures/sprites interior/`

Principais arquivos:
- `TopDownHouse_DoorsAndWindows.png` - Portas e janelas para ambientes internos
- `TopDownHouse_FloorsAndWalls_OpenDoors.png` - Pisos e paredes com portas abertas
- Outros elementos para decoração de ambientes internos

### Organização de Tileset
Os tilesets são organizados seguindo um padrão consistente:
- Agrupamento lógico por tipo (piso, parede, objetos)
- Padronização de tamanho dos tiles
- Consistência de estilo artístico

## Elementos de Interface do Usuário

### Botões
Localização: `assets/interface/buttons/BotãoMenu.tscn`

- Estilo: Consistente com a estética pixel art do jogo
- Estados: Normal, Hover, Pressed, Disabled
- Componentes: Textura de fundo, texto, efeitos de hover

### Ícones
Localização: `assets/interface/icons/`

Principais ícones:
- `All.png` - Coleção de ícones diversos
- `config.png` - Ícone para configurações
- `Pause.svg` - Ícone de pausa (formato vetorial)
- `volta.png` - Ícone para botão de retorno

### Pack UI Pixel
Localização: `assets/interface/icons/Pixel UI pack 3/`

- Conjunto completo de elementos de UI no estilo pixel art
- Inclui botões, barras, indicadores e decorações

## Fontes

### Daydream
Localização: `assets/fonts/daydream_3/`

- Arquivo: `Daydream.ttf`
- Estilo: Pixel art retro
- Licença: Licença pessoal (ver `Daydream 1.0 Personal License.txt`)
- Uso principal: Títulos e elementos de destaque

### Pixellari
Localização: `assets/fonts/pixellari/`

- Arquivo: `Pixellari.ttf`
- Estilo: Pixel art legível
- Uso principal: Texto de diálogo e elementos de interface

## Joystick Virtual

Localização: `assets/textures/VirtualJoystickPack/`

- Conjunto de texturas para joystick virtual em dispositivos móveis
- Personalização através do script `touch_screen_joystick.gd`

## Diretrizes de Estilo Visual

### Paleta de Cores
O projeto segue uma paleta de cores consistente para manter coesão visual:
- Cores primárias para elementos principais da interface
- Cores secundárias para destaques e ações
- Tons neutros para textos e elementos de fundo

### Proporções e Escalas
- Personagens: Aproximadamente 234x350 pixels
- Tiles de ambiente: Tamanho padrão de 16x16 ou 32x32 pixels
- Interface: Elementos dimensionados para visibilidade em diferentes resoluções

### Animações
- Os personagens usam animações frame-a-frame
- Recomenda-se criar animações para: idle, andando, interagindo
- Frame rate recomendado: 8-12 FPS para manter a estética pixel art

## Como Usar os Recursos Artísticos

### Importando Novos Sprites
1. Adicione o arquivo na pasta apropriada em `assets/`
2. Importe o arquivo no Godot (clique direito → Import)
3. Configure as propriedades de importação (filtro, compressão)
4. Crie o arquivo .import correspondente

Exemplo de configuração para sprite sheets:
```
[remap]
importer="texture"
type="CompressedTexture2D"
path="res://.godot/imported/seu-sprite.png-XXXXXXXXXXXXXXXX.ctex"
metadata={
"vram_texture": false
}

[deps]
source_file="res://assets/character sprites/seu-sprite.png"
dest_files=["res://.godot/imported/seu-sprite.png-XXXXXXXXXXXXXXXX.ctex"]

[params]
compress/mode=0
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/bptc_ldr=0
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/HDR_as_SRGB=false
process/size_limit=0
detect_3d/compress_to=1
```

### Criando Novos Elementos de Interface
1. Use os templates existentes como base (ex: `BotãoMenu.tscn`)
2. Mantenha a consistência com o estilo visual existente
3. Organize os elementos em containers para melhor responsividade
4. Teste em diferentes resoluções

### Animando Sprites
1. Crie as animações no Aseprite (arquivos .ase disponíveis)
2. Exporte como sprite sheet
3. Configure o `AnimationPlayer` no Godot:
   - Crie animações separadas (idle, walk, etc.)
   - Configure frames e duração
   - Adicione eventos em frames específicos quando necessário

## Créditos e Licenças

- Fonte Daydream: Licença pessoal (ver arquivo de licença)
- Fonte Pixellari: Licença incluída
- Sprites e texturas: Criação própria ou com licença apropriada

## Diretrizes para Novos Assets

Ao criar novos recursos visuais para o projeto:
1. Mantenha o estilo pixel art consistente
2. Siga a paleta de cores existente
3. Respeite as proporções estabelecidas
4. Documente fontes e licenças
5. Forneça arquivos fonte quando possível (.ase, .psd)

## Ferramentas Recomendadas

- **Aseprite**: Para criação e edição de sprites e animações pixel art
- **GIMP/Photoshop**: Para edição de imagens mais complexas
- **TexturePacker**: Para organizar sprite sheets
- **FontForge**: Para edição ou criação de fontes pixel art

extends Node

# NPCManager - Autoload para gerenciar todos os NPCs do jogo
# Este script permite registrar NPCs com suas características definidas
# e recuperá-los facilmente em qualquer parte do jogo

# Dicionário para armazenar informações dos NPCs
# Estrutura: { "nome_do_npc": { dados_do_npc }, ... }
var npcs: Dictionary = {}

# Constante para diretório de fontes
const FONTS_DIR = "res://assets/fonts/"

# Constante para diretório de áudios
const AUDIO_DIR = "res://assets/audio/sfx/"

# Constante para diretório de sprites de NPC
const NPC_SPRITES_DIR = "res://assets/character sprites/"

# Propriedades padrão para todos os NPCs
const DEFAULT_FONT = "pixellari/Pixellari.ttf"
const DEFAULT_DIALOGUE_SOUND = "dialogue_typing.wav"
const DEFAULT_FONT_SIZE = 16
const DEFAULT_TEXT_COLOR = Color(1, 1, 1, 1)  # Branco

func _ready() -> void:
	print("NPC Manager inicializado")
	# Pré-registrar NPCs que conhecemos
	_register_default_npcs()

# Registra um novo NPC ou atualiza um existente
func register_npc(npc_id: String, display_name: String, sprite_path: String = "", 
				 font_path: String = DEFAULT_FONT, font_size: int = DEFAULT_FONT_SIZE, 
				 text_color: Color = DEFAULT_TEXT_COLOR, dialogue_sound: String = DEFAULT_DIALOGUE_SOUND,
				 custom_properties: Dictionary = {}) -> void:
	
	# Verificar se já existe
	if npcs.has(npc_id):
		print("NPC atualizado: ", npc_id)
	else:
		print("Novo NPC registrado: ", npc_id)
	
	# Se o sprite_path for relativo (não começa com res://)
	if sprite_path != "" and not sprite_path.begins_with("res://"):
		sprite_path = NPC_SPRITES_DIR + sprite_path
	
	# Se o font_path for relativo
	if font_path != "" and not font_path.begins_with("res://"):
		font_path = FONTS_DIR + font_path
	
	# Se o dialogue_sound for relativo
	if dialogue_sound != "" and not dialogue_sound.begins_with("res://"):
		dialogue_sound = AUDIO_DIR + dialogue_sound
	
	# Criar dicionário com dados do NPC
	var npc_data = {
		"id": npc_id,
		"display_name": display_name,
		"sprite_path": sprite_path,
		"font_path": font_path,
		"font_size": font_size,
		"text_color": text_color,
		"dialogue_sound": dialogue_sound,
		"custom_properties": custom_properties
	}
	
	# Registrar no dicionário principal
	npcs[npc_id] = npc_data

# Recupera os dados de um NPC pelo ID
func get_npc_data(npc_id: String) -> Dictionary:
	if npcs.has(npc_id):
		return npcs[npc_id]
	else:
		push_warning("NPC não encontrado: " + npc_id + ". Retornando dados vazios.")
		return {}

# Recupera o nome de exibição de um NPC
func get_npc_display_name(npc_id: String) -> String:
	if npcs.has(npc_id):
		return npcs[npc_id].display_name
	return "NPC Desconhecido"

# Recupera o caminho para o sprite de um NPC
func get_npc_sprite_path(npc_id: String) -> String:
	if npcs.has(npc_id):
		return npcs[npc_id].sprite_path
	return ""

# Recupera a fonte (DynamicFont) para um NPC específico
func get_npc_font(npc_id: String) -> Font:
	var font_path = ""
	var font_size = DEFAULT_FONT_SIZE
	
	if npcs.has(npc_id):
		font_path = npcs[npc_id].font_path
		font_size = npcs[npc_id].font_size
	else:
		font_path = FONTS_DIR + DEFAULT_FONT
	
	# Tentar carregar a fonte
	if ResourceLoader.exists(font_path):
		var font_resource = load(font_path)
		# Configurar tamanho se for uma fonte dinâmica
		if font_resource is FontFile:
			return font_resource
	
	# Fallback
	push_warning("Não foi possível carregar a fonte para o NPC: " + npc_id)
	return null

# Recupera a cor do texto para um NPC
func get_npc_text_color(npc_id: String) -> Color:
	if npcs.has(npc_id):
		return npcs[npc_id].text_color
	return DEFAULT_TEXT_COLOR

# Recupera o caminho para o som de diálogo de um NPC
func get_npc_dialogue_sound(npc_id: String) -> String:
	if npcs.has(npc_id):
		return npcs[npc_id].dialogue_sound
	return AUDIO_DIR + DEFAULT_DIALOGUE_SOUND

# Toca o som de diálogo específico do NPC usando o AudioManager
func play_npc_dialogue_sound(npc_id: String, volume: float = 0.2, pitch_scale: float = 1.0) -> void:
	var sound_name = ""
	
	if npcs.has(npc_id) and npcs[npc_id].dialogue_sound.ends_with(".wav"):
		# Extrair nome do arquivo sem extensão para usar com AudioManager
		var file_name = npcs[npc_id].dialogue_sound.get_file().get_basename()
		sound_name = file_name
	else:
		sound_name = "dialogue_typing"  # Nome padrão registrado no AudioManager
	
	# Tocar o som usando AudioManager (sem verificação, já que é autoload)
	AudioManager.play_sfx(sound_name, volume, pitch_scale)

# Função auxiliar para carregar sprites
func load_npc_sprite(npc_id: String) -> Texture2D:
	var sprite_path = ""
	
	if npcs.has(npc_id):
		sprite_path = npcs[npc_id].sprite_path
	
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		return load(sprite_path)
	
	push_warning("Sprite não encontrado para o NPC: " + npc_id)
	return null

# Função auxiliar para adicionar propriedade personalizada a um NPC
func set_npc_custom_property(npc_id: String, property_name: String, value) -> void:
	if npcs.has(npc_id):
		npcs[npc_id].custom_properties[property_name] = value
	else:
		push_warning("Tentativa de definir propriedade para NPC inexistente: " + npc_id)

# Função auxiliar para obter propriedade personalizada de um NPC
func get_npc_custom_property(npc_id: String, property_name: String, default_value = null):
	if npcs.has(npc_id) and npcs[npc_id].custom_properties.has(property_name):
		return npcs[npc_id].custom_properties[property_name]
	return default_value

# Registra os NPCs padrão do jogo
func _register_default_npcs() -> void:
	# NPCs pré-configurados
	register_npc(
		"jucira", 
		"Jucira",
		"Sprite Prota.png",  # Sprite temporário - substitua pelo sprite correto
		"pixellari/Pixellari.ttf",  # Fonte
		16,  # Tamanho da fonte
		Color(0.9, 0.6, 0.6),  # Cor do texto (tom de rosa claro)
		"dialogue_typing.wav",  # Som de diálogo
		{"profissao": "Moradora da vila", "idade": 58} # Propriedades personalizadas
	)
	
	# Outros NPCs pré-configurados podem ser adicionados aqui
	register_npc(
		"vizinho", 
		"Vizinho",
		"Sprite EmDuvida.png",  # Sprite
		"pixellari/Pixellari.ttf",  # Fonte
		16,  # Tamanho da fonte
		Color(1, 1, 1),  # Cor do texto (branco)
		"dialogue_typing.wav"  # Som de diálogo
	)
	
	register_npc(
		"prefeito",
		"Prefeito", 
		"Sprite Expressao.png", 
		"daydream_3/Daydream.ttf", 
		18, 
		Color(0.8, 0.8, 1),  # Azulado
		"dialogue_typing.wav" 
	)
	
	register_npc(
		"comerciante",
		"Comerciante",
		"Sprite Prota dormindo.png",
		"kiwisoda/KiwiSoda.ttf",
		16,
		Color(1, 0.9, 0.7),  # Amarelado
		"dialogue_typing.wav"
	)

# Verifica se um NPC existe no registro
func npc_exists(npc_id: String) -> bool:
	return npcs.has(npc_id)

# Lista todos os IDs de NPCs registrados
func get_all_npc_ids() -> Array:
	return npcs.keys()

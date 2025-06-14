extends Node2D

# Level1.gd - Script básico para o nível 1

var state_manager
var service_locator
var audio_manager
var hud

func _ready():
	# Obter referências aos serviços
	service_locator = $"/root/ServiceLocator"
	state_manager = service_locator.get_service("StateManager")
	audio_manager = service_locator.get_service("AudioManager")
	hud = service_locator.get_service("HUD")
	
	# Verificar se o jogador existe e conectar sinais
	var player = $Player
	if player:
		hud.interaction_requested.connect(player._on_interaction_requested)
	
	# Iniciar música de fundo do nível
	audio_manager.play_music("level_theme", "res://assets/audio/music/level_theme.ogg")
	
	# Configurar interações de objetos
	_setup_interactive_objects()

# Configurar objetos interativos
func _setup_interactive_objects():
	var objects = $Objects.get_children()
	for obj in objects:
		if obj.has_method("setup_interaction"):
			obj.setup_interaction()

# Chamado quando o nível é finalizado
func complete_level():
	# Lógica para completar o nível (ex: desbloquear próximo nível, mostrar pontuação)
	state_manager.change_state("MainMenu")

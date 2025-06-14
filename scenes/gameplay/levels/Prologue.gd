extends Node2D

# Prologue.gd - Script para gerenciar o nível do prólogo com a nova arquitetura

# Referências aos gerenciadores
var state_manager
var audio_manager
var scene_manager
var hud

# Controle do estado do prólogo
var prologue_completed = false

func _ready():
	# Obter referências aos serviços
	var service_locator = $"/root/ServiceLocator"
	if service_locator:
		state_manager = service_locator.get_service("StateManager")
		audio_manager = service_locator.get_service("AudioManager")
		scene_manager = service_locator.get_service("SceneManager")
		hud = service_locator.get_service("HUD")
	
	# Tocar música de fundo do prólogo
	if audio_manager:
		audio_manager.play_music("prologue_theme", "res://scenes/prologue/Início/music/prologue_theme.ogg")
	
	# Conectar o sinal de finalização do prólogo, se disponível
	var prologue_scene = $PrologueScene
	if prologue_scene and prologue_scene.has_signal("prologue_completed"):
		prologue_scene.connect("prologue_completed", _on_prologue_completed)

# Chamado quando o prólogo é concluído
func _on_prologue_completed():
	prologue_completed = true
	
	# Transição para o primeiro nível ou para o menu principal
	if state_manager:
		state_manager.change_state("Gameplay")  # Ou outro estado configurado

# Pular o prólogo (chamado por um botão, se necessário)
func skip_prologue():
	if audio_manager:
		audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	
	prologue_completed = true
	
	if state_manager:
		state_manager.change_state("Gameplay")

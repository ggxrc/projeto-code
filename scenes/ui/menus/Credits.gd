extends Control

# Credits.gd - Script para a tela de créditos

# Referências
@onready var back_button = $BackButton

# Gerenciadores
var state_manager
var audio_manager

func _ready():
	# Conectar sinais
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Obter referências aos serviços
	var service_locator = $"/root/ServiceLocator"
	state_manager = service_locator.get_service("StateManager")
	audio_manager = service_locator.get_service("AudioManager")
	
	# Tocar música dos créditos (opcional)
	# audio_manager.play_music("credits_theme", "res://assets/audio/music/credits_theme.ogg")

# Callback para o botão voltar
func _on_back_button_pressed():
	audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg")
	state_manager.change_state("MainMenu")

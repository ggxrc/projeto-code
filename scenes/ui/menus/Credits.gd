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
	audio_manager.play_music("credits_theme", "res://assets/audio/music/credits_theme.ogg", 0.0)

# Callback para o botão voltar
func _on_back_button_pressed():
	audio_manager.play_ui_sound("button_click", "res://assets/audio/ui/button_click.ogg", 1.0)
	state_manager.change_state("MainMenu")

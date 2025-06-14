extends Node

# Referências para os sliders de volume
@onready var master_slider = $CanvasLayer/Control/ColorRect/VBoxContainer/ConfigContainer/MasterVolumeContainer/MasterBar
@onready var music_slider = $CanvasLayer/Control/ColorRect/VBoxContainer/ConfigContainer/MusicVolumeContainer/MusicBar
@onready var sfx_slider = $CanvasLayer/Control/ColorRect/VBoxContainer/ConfigContainer/SFXVolumeContainer/SFXBar
@onready var voltar_button = $CanvasLayer/Control/ColorRect/VBoxContainer/ButtonContainer/VoltarFromConfig
@onready var button_click_player = $ButtonClick

func _ready() -> void:
	print("Config: Inicializando tela de configurações")
	
	# Define um volume mínimo para exibição (evita sliders zerados)
	var min_display_volume = 0.05  # 5% como mínimo
	
	# Conecta os sinais dos sliders
	if master_slider:
		master_slider.value_changed.connect(_on_master_volume_changed)
		# Inicializa com o valor atual do AudioManager (garantindo mínimo sensato)
		var master_vol = max(AudioManager.master_volume, min_display_volume)
		master_slider.value = master_vol * 100
		print("Config: Slider de master configurado com valor inicial: ", master_slider.value)
	else:
		push_error("Config: Slider de master não encontrado!")
	
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
		# Inicializa com o valor atual do AudioManager (garantindo mínimo sensato)
		var music_vol = max(AudioManager.music_volume, min_display_volume)
		music_slider.value = music_vol * 100
		print("Config: Slider de música configurado com valor inicial: ", music_slider.value)
	else:
		push_error("Config: Slider de música não encontrado!")
	
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
		# Inicializa com o valor atual do AudioManager (garantindo mínimo sensato)
		var sfx_vol = max(AudioManager.sfx_volume, min_display_volume)
		sfx_slider.value = sfx_vol * 100
		print("Config: Slider de SFX configurado com valor inicial: ", sfx_slider.value)
	else:
		push_error("Config: Slider de SFX não encontrado!")
			
	# Conecta o botão de voltar
	if voltar_button:
		voltar_button.pressed.connect(_on_voltar_pressed)
		print("Config: Botão de voltar configurado")
	else:
		push_error("Config: Botão de voltar não encontrado!")

func _on_master_volume_changed(value: float) -> void:
	print("Config: Alterando volume master para ", value)
	AudioManager.set_master_volume(value / 100)  # Converte de 0-100 para 0-1

func _on_music_volume_changed(value: float) -> void:
	print("Config: Alterando volume da música para ", value)
	AudioManager.set_music_volume(value / 100)  # Converte de 0-100 para 0-1
	
	# Tocar música de exemplo se não houver música tocando
	if not AudioManager.music_player.playing:
		print("Config: Tocando música de exemplo para teste")
		AudioManager.play_music("menu")

func _on_sfx_volume_changed(value: float) -> void:
	print("Config: Alterando volume de SFX para ", value)
	AudioManager.set_sfx_volume(value / 100)  # Converte de 0-100 para 0-1
	
	# Tocar um som para testar o volume
	AudioManager.play_sfx("button_click")

func _on_voltar_pressed() -> void:
	# Reproduz som de clique
	AudioManager.play_sfx("button_click")
	
	# Salva as configurações antes de sair
	AudioManager.save_settings()
	
	# Volta para a tela anterior
	var orquestrador = _get_orquestrador()
	if orquestrador:
		if orquestrador.has_method("close_options"):
			print("Config: Fechando opções através do orquestrador")
			orquestrador.close_options()
		elif orquestrador.has_method("close_options_from_pause"):
			print("Config: Fechando opções a partir do menu de pausa")
			orquestrador.close_options_from_pause()
		else:
			print("Config: Orquestrador não tem método para fechar opções")
	else:
		push_warning("Config: Não foi possível encontrar o orquestrador")

# Método auxiliar para obter referência ao orquestrador
func _get_orquestrador():
	var orquestrador = null
	
	# Tenta várias possibilidades de path para o orquestrador
	var possible_paths = [
		"/root/Game/Orquestrador",
		"../Orquestrador",
		"/root/Orquestrador",
		"/root/Game"
	]
	
	for path in possible_paths:
		orquestrador = get_node_or_null(path)
		if orquestrador:
			print("Orquestrador encontrado em: ", path)
			break
	
	if not orquestrador:
		print("Não foi possível encontrar o Orquestrador em nenhum caminho conhecido")
	
	return orquestrador

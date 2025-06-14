extends Node

# Referências para os sliders de volume
@onready var music_slider = $CanvasLayer/Control/ColorRect/MusicBar/HSlider
@onready var sfx_slider = $CanvasLayer/Control/ColorRect/SfxBar/HSlider
@onready var voltar_button = $CanvasLayer/Control/VoltarFromConfig

func _ready() -> void:
	print("Config: Inicializando tela de configurações")
	
	# Define um volume mínimo para exibição (evita sliders zerados)
	var min_display_volume = 0.05  # 5% como mínimo
	
	# Conecta os sinais dos sliders
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
	_save_audio_settings()
	
func _save_audio_settings() -> void:
	print("Config: Salvando configurações de áudio")
	
	var config = ConfigFile.new()
	
	# Define os valores a serem salvos
	config.set_value("audio", "music_volume", AudioManager.music_volume)
	config.set_value("audio", "sfx_volume", AudioManager.sfx_volume)
	config.set_value("audio", "master_volume", AudioManager.master_volume)
	
	# Salva o arquivo
	var err = config.save("user://audio_settings.cfg")
	if err != OK:
		push_error("Config: Erro ao salvar configurações de áudio: " + str(err))
	else:
		print("Config: Configurações salvas com sucesso.")

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

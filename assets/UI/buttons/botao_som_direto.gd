extends Button

# Este é um script simplificado para botões
# Ele apenas toca o som quando o botão é clicado

func _ready():
	# Usar um sinal direto em vez de conectar via código
	# Isso evita conexões duplicadas potenciais
	pass

func _pressed():
	# Esta é a função built-in chamada quando o botão é pressionado
	print("BOTÃO PRESSIONADO - Tentando tocar som...")
	
	# Tocar o som diretamente com volume alto
	AudioManager.set_sfx_volume(1.0)  # Garantir volume máximo
	AudioManager.play_sfx("button_click", 1.0, 1.0)  # Volume e pitch máximos
	
	# Também criar um player direto para garantir
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = 0  # Volume máximo
	
	# Tentar carregar o arquivo de áudio diretamente
	var sound_path = "res://assets/audio/sfx/button_click.wav"
	if ResourceLoader.exists(sound_path):
		var sound = load(sound_path)
		if sound:
			player.stream = sound
			player.play()
			print("Tocando som diretamente via AudioStreamPlayer")
			
			# Remover o player quando o som terminar
			player.finished.connect(func(): player.queue_free())
		else:
			print("Falha ao carregar o som")
	else:
		print("Arquivo de som não encontrado:", sound_path)

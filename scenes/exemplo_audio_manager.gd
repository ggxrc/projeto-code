extends Node

# Este é um exemplo de como usar o AudioManager em diferentes situações

func _ready():
	print("Exemplo de uso do AudioManager carregado!")
	
	# Verificar se o AudioManager está disponível
	if not Engine.has_singleton("AudioManager"):
		print("ERRO: AudioManager não está registrado como singleton!")
		print("Verifique se o AudioManager.tscn está configurado como autoload no Project Settings.")
		return
	
	# Tocar a música de fundo com fade in de 2 segundos
	var audio_manager = Engine.get_singleton("AudioManager")
	audio_manager.play_music("menu", 2.0)
	
	# Mostrar quais músicas estão disponíveis
	print("Músicas disponíveis:")
	for music_name in audio_manager.music_paths.keys():
		print("- " + music_name)
	
	# Mostrar quais efeitos sonoros estão disponíveis
	print("Efeitos sonoros disponíveis:")
	for sfx_name in audio_manager.sfx_paths.keys():
		print("- " + sfx_name)

# Função de exemplo para tocar um efeito sonoro
func tocar_efeito_sonoro(nome_do_efeito: String) -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx(nome_do_efeito)
		print("Tocando efeito: " + nome_do_efeito)
	else:
		print("AudioManager não encontrado!")

# Função de exemplo para mudar a música
func mudar_musica(nome_da_musica: String, fade_time: float = 1.0) -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		# Fade out da música atual
		audio_manager.stop_music(fade_time)
		# Aguarda o fade out terminar antes de iniciar a nova música
		await get_tree().create_timer(fade_time).timeout
		# Toca a nova música com fade in
		audio_manager.play_music(nome_da_musica, fade_time)
		print("Mudando para música: " + nome_da_musica)
	else:
		print("AudioManager não encontrado!")

# Função de exemplo para ajustar o volume
func ajustar_volume(tipo: String, valor: float) -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		
		match tipo:
			"master":
				audio_manager.set_master_volume(valor)
				print("Volume master ajustado para: " + str(valor))
			"music":
				audio_manager.set_music_volume(valor)
				print("Volume da música ajustado para: " + str(valor))
			"sfx":
				audio_manager.set_sfx_volume(valor)
				print("Volume dos efeitos ajustado para: " + str(valor))
	else:
		print("AudioManager não encontrado!")

# Como usar: Adicione este script a um Node em qualquer cena e chame estas funções
# Exemplo: 
# - get_node("ExemploAudioManager").tocar_efeito_sonoro("button_click")
# - get_node("ExemploAudioManager").mudar_musica("gameplay")
# - get_node("ExemploAudioManager").ajustar_volume("music", 0.5)

extends Node

# Script de exemplo mostrando como usar o AudioManager em diferentes partes do jogo

# === EXEMPLO: MENU PRINCIPAL ===

# Quando o menu principal é carregado
func _on_menu_principal_ready() -> void:
	# Verificar se o AudioManager está disponível como singleton
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		# Tocar a música de fundo do menu com fade in de 2 segundos
		audio_manager.play_music("menu", 2.0)

# Quando um botão é clicado
func _on_button_pressed() -> void:
	# Verificar se o AudioManager está disponível
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		# Tocar efeito sonoro de clique
		audio_manager.play_sfx("button_click")
		# Se o botão for "Novo Jogo", podemos fazer uma transição
	# Fade out da música atual e fade in da nova
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.stop_music(1.0)  # Fade out de 1 segundo
		await get_tree().create_timer(1.0).timeout
		audio_manager.play_music("prologue", 1.0)  # Fade in de 1 segundo

# === EXEMPLO: SISTEMA DE DIÁLOGOS ===

# Quando um diálogo é iniciado
func _on_dialogue_started() -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		# Podemos diminuir um pouco o volume da música de fundo
		var current_volume = audio_manager.music_volume
		audio_manager.set_music_volume(current_volume * 0.7)  # Reduz para 70% do volume

# Quando um caractere é digitado na caixa de diálogo
func _on_character_typed() -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		# Tocar som de digitação com volume baixo e pitch aleatório
		# para evitar monotonia
		var random_pitch = randf_range(0.9, 1.1)
		audio_manager.play_sfx("dialogue_typing", 0.3, random_pitch)

# Quando o diálogo termina
func _on_dialogue_ended() -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		# Restaurar o volume da música
		audio_manager.set_music_volume(0.8)

# === EXEMPLO: JOGADOR ===

# No sistema de movimento do jogador
func _on_player_moved() -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		# Tocar som de passos quando o jogador se move
		# Variamos o pitch para evitar monotonia
		var random_pitch = randf_range(0.9, 1.1)
		audio_manager.play_sfx("footstep", 0.5, random_pitch)

# Quando o jogador interage com um objeto
func _on_player_interacted() -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("interact")

# === EXEMPLO: CONFIGURAÇÕES DO JOGO ===

# Quando o jogador ajusta o volume
func _on_master_volume_changed(value: float) -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.set_master_volume(value)

func _on_music_volume_changed(value: float) -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.set_music_volume(value)

func _on_sfx_volume_changed(value: float) -> void:
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.set_sfx_volume(value)
		
		# Tocar um sfx para testar o volume escolhido
		audio_manager.play_sfx("button_click")

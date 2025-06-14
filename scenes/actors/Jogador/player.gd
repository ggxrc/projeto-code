extends CharacterBody2D

# Certifique-se que as classes de interação sejam carregadas
const InteractiveObjectClass = preload("res://scripts/interactive_object.gd")
const InteractiveDoorClass = preload("res://scripts/interactive_door.gd")

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var botao_toque = $CanvasLayer/BotaoToque

# Sistema de interação universal
var objeto_interagivel_atual = null
var pode_interagir = false
var raio_interacao = 100.0
signal interacao_realizada(objeto)

# Dicionário de textos de interação para diferentes tipos de objetos
var textos_interacao = {
	"porta": "Abrir Porta",
	"porta_trancada": "Porta Trancada",
	"alavanca": "Puxar Alavanca",
	"musica": "Tocar Música",
	"computador": "Usar Computador",
	"bau": "Abrir Baú",
	"item": "Pegar Item",
	"default": "Interagir"
}

# Tempo de inatividade (em segundos) antes de mudar para animação "sleeping"
const IDLE_TIMEOUT = 10.0
var idle_timer = 0.0
var is_moving = false
var last_direction = Vector2.DOWN  # Armazena a última direção do movimento
var was_idle_last_frame = true     # Controla se o jogador estava parado no frame anterior

# Timer para controlar a frequência dos sons de passos
var footstep_sound_timer = 0.0

func _ready() -> void:
	# Configura a animação padrão - começamos com o jogador olhando para baixo
	if sprite:
		last_direction = Vector2.DOWN
		play_idle_in_direction(last_direction)
		was_idle_last_frame = true  # Inicializa como parado
		
	# Debug - Imprime as animações disponíveis
	if sprite and sprite.sprite_frames:
		print("Animações disponíveis: ", sprite.sprite_frames.get_animation_names())
		
	# Detecta se estamos em uma plataforma móvel e adiciona um joystick se necessário
	if OS.get_name() == "Android" or OS.get_name() == "iOS" or OS.has_feature("mobile"):
		add_virtual_joystick()
		# Esconde o joystick imediatamente para evitar que apareça sobre a tela inicial
		hide_joystick()
		
	# Registra para receber notificações de mudança de estado do jogo
	call_deferred("register_for_game_state_changes")
	
	# Após setup inicial, configura a visibilidade do joystick com base no estado atual
	# Usamos call_deferred para garantir que seja chamado após a cena estar completamente configurada
	call_deferred("update_joystick_visibility")
	
	# Configurar o botão Toque
	if botao_toque:
		botao_toque.pressed.connect(_on_botao_interacao_pressed)
		botao_toque.visible = false  # Inicialmente invisível

func add_virtual_joystick() -> void:
	# Verifica se já existe um joystick
	if find_joystick():
		return
		
	# Cria um CanvasLayer para o joystick (para ficar sobre outros elementos)
	var canvas = CanvasLayer.new()
	canvas.name = "JoystickLayer"
	canvas.layer = 10  # Coloca na frente de outros elementos
	
	# Importante: Começa invisível para evitar sobreposição com texto inicial
	canvas.visible = false
	
	get_tree().root.add_child(canvas)
	
	# Cria o joystick
	var joystick = TouchScreenJoystick.new()
	joystick.name = "VirtualJoystick"
	joystick.size = Vector2(300, 300)
	joystick.position = Vector2(150, 500)  # Ajuste conforme necessário para seu layout
	joystick.mode = 1  # Modo dinâmico
	joystick.use_textures = true
	
	# Você pode definir texturas se disponíveis
	# joystick.knob_texture = load("res://assets/interface/joystick_knob.png")
	# joystick.base_texture = load("res://assets/interface/joystick_base.png")
	
	canvas.add_child(joystick)
	print("Player: Joystick virtual criado (inicialmente oculto)")

func _physics_process(delta: float) -> void:
	# Captura a entrada de movimento (teclado ou joystick virtual)
	var dir := Vector2.ZERO
	
	# Só processa input se o joystick estiver visível (controle habilitado)
	if is_joystick_visible():
		# Primeiro tenta obter input do teclado
		dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
		
		# Se não houver input do teclado, procura por joystick virtual
		if dir == Vector2.ZERO:
			var joystick = find_joystick()
			if joystick and joystick.is_pressing and not joystick.is_in_deadzone():
				dir = joystick.get_output()
	
	var was_moving = is_moving  # Guarda o estado anterior para detectar mudanças
	
	if dir:
		# Aplica o movimento com base na entrada
		velocity = dir * 200
		
		# Atualiza a animação e a direção
		update_animation(dir)
		last_direction = dir  # Armazena a última direção para uso ao parar
		
		# Reset estado de inatividade
		is_moving = true
		
		# Tocar som de passos com intervalo (a cada 0.3 segundos)
		if Engine.has_singleton("AudioManager") and footstep_sound_timer <= 0:
			var audio_manager = Engine.get_singleton("AudioManager")
			var random_pitch = randf_range(0.9, 1.1)
			audio_manager.play_sfx("footstep", 0.3, random_pitch)
			footstep_sound_timer = 0.3  # Intervalo entre sons de passos
		
		# Enquanto se movimenta, verificar objetos interativos
		verificar_objetos_interagiveis()
		idle_timer = 0.0
		
		# Decrementar o timer de som de passos
		if footstep_sound_timer > 0:
			footstep_sound_timer -= delta
	else:
		# Desacelera o movimento quando não há entrada
		velocity.x = move_toward(velocity.x, 0, 200)
		velocity.y = move_toward(velocity.y, 0, 200)
		
		# Verifica se está realmente parado (velocidade próxima de zero)
		is_moving = is_actually_moving()
		
		# Verifica se acabou de parar (transição de movimento para parado)
		if was_moving and not is_moving:
			if sprite:
				# Quando para, mantém a direção que estava olhando usando o primeiro frame
				play_idle_in_direction(last_direction)
				# Reinicia o temporizador
				idle_timer = 0.0
		elif not is_moving:
			# Já estava parado, incrementa o temporizador de inatividade
			idle_timer += delta
			
			# Após 5 segundos, muda para a animação "idle" se não estiver em uma animação especial
			if idle_timer > 5.0 and sprite and sprite.animation != "idle" and sprite.animation != "sleeping":
				sprite.play("idle")
				
			# Após o tempo definido em IDLE_TIMEOUT, muda para "sleeping"
			elif idle_timer > IDLE_TIMEOUT and sprite and sprite.animation != "sleeping":
				sprite.play("sleeping")
	
	move_and_slide()
	
func update_animation(direction: Vector2) -> void:
	if not sprite:
		return
		
	var starting_frame = 0
	
	# Se o jogador estava parado e agora está se movendo, começamos no segundo frame (índice 1)
	# Isso evita o efeito de "deslizamento" quando o jogador começa a andar
	if was_idle_last_frame:
		starting_frame = 1
		was_idle_last_frame = false
	
	# Determina a animação com base na direção principal do movimento
	if abs(direction.x) > abs(direction.y):
		# Movimento horizontal é dominante
		if direction.x > 0:
			sprite.play("direita")
			sprite.flip_h = false
		else:
			sprite.play("esquerda")
			sprite.flip_h = false
	else:
		# Movimento vertical é dominante
		if direction.y > 0:
			sprite.play("baixo")
		else:
			sprite.play("cima")
	
	# Configura o frame inicial para evitar deslizamento
	if starting_frame > 0 and sprite.sprite_frames.get_frame_count(sprite.animation) > starting_frame:
		sprite.frame = starting_frame
			
func _input(event: InputEvent) -> void:
	# Detecta tecla E para interação com objetos
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		# Verifica se há algum objeto disponível para interação
		if pode_interagir and objeto_interagivel_atual:
			interagir_com_objeto(objeto_interagivel_atual)
	
	# Só processa input se o joystick estiver visível (controle habilitado)
	if is_joystick_visible() and (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
		if event.is_pressed():
			# Se qualquer tecla foi pressionada enquanto está em estado idle/sleeping
			if sprite and (sprite.animation == "sleeping" or sprite.animation == "idle"):
				# Volta para o estado de parado, olhando na última direção
				play_idle_in_direction(last_direction)
				idle_timer = 0.0
				was_idle_last_frame = true  # Marca que estava parado para a próxima animação de movimento
			
# Tenta encontrar um joystick virtual na cena
func find_joystick():
	# Procura primeiro nos nós pai (UI pode estar em outra árvore)
	var parent = get_parent()
	while parent:
		# Tenta encontrar o joystick nos filhos do nó pai
		for child in parent.get_children():
			if child is TouchScreenJoystick:
				return child
				
		# Move para o próximo pai
		parent = parent.get_parent()
	
	# Se não encontrou nos pais, procura na árvore de cena global
	var root = get_tree().root
	var joystick = find_joystick_recursive(root)
	
	return joystick

# Função para esconder o joystick virtual
func hide_joystick() -> void:
	var joystick = find_joystick()
	if joystick:
		var parent = joystick.get_parent()
		if parent:
			parent.visible = false

# Função para mostrar o joystick virtual
func show_joystick() -> void:
	var joystick = find_joystick()
	if joystick:
		var parent = joystick.get_parent()
		if parent:
			parent.visible = true

# Função para verificar se o joystick deve estar visível com base no estado atual do jogo
func update_joystick_visibility() -> void:
	# Tenta obter referência ao Game (orquestrador)
	var game = get_node_or_null("/root/Game")
	if not game:
		print("Player: Não foi possível encontrar o orquestrador Game")
		return
		
	# Verifica se existe um método para verificar o estado do jogo
	if not game.has_method("is_game_in_state"):
		print("Player: Game não possui o método is_game_in_state")
		return
	
	# Pega o valor dos estados do Game
	var GameState = game.get("GameState")
	if not GameState:
		print("Player: Não foi possível acessar GameState")
		return
	
	# Verifica se a tela inicial está visível (tela de diálogo inicial)
	var tela_inicial_visivel = false
	var prologue_node = game.get_node_or_null("Prologue")
	if prologue_node and prologue_node.has_node("TelaInicial"):
		var tela_inicial = prologue_node.get_node("TelaInicial")
		tela_inicial_visivel = tela_inicial and tela_inicial.visible
	
	# Verifica se qualquer diálogo está ativo
	var dialogue_active = false
	if has_node("/root/GameUtils"):
		var game_utils = get_node("/root/GameUtils")
		if game_utils.has_method("is_dialogue_active"):
			dialogue_active = game_utils.is_dialogue_active()
	
	# Verifica diretamente nodes de diálogo no prólogo
	var dialogue_box_visivel = false
	if prologue_node:
		var dialogue_boxes = ["DialogueBoxUI", "ChoiceDialogueBox", "DescriptionBoxUI"]
		for box_name in dialogue_boxes:
			var box = prologue_node.get_node_or_null(box_name)
			if box and box.visible:
				dialogue_box_visivel = true
				break
		
	# Verifica se o jogo está no estado de PROLOGUE ou PLAYING e se não há diálogos ativos
	if (game.is_game_in_state(GameState.PROLOGUE) or game.is_game_in_state(GameState.PLAYING)) and \
	   not dialogue_active and not tela_inicial_visivel and not dialogue_box_visivel:
		show_joystick()
	else:
		# Esconder em qualquer outro caso:
		# - Em outros estados (MENU, PAUSED, OPTIONS, CONFIG_FROM_PAUSE)
		# - Quando há diálogos ativos
		# - Quando a tela inicial está visível
		hide_joystick()

# Verifica se o joystick está visível
func is_joystick_visible() -> bool:
	var joystick = find_joystick()
	if joystick:
		var parent = joystick.get_parent()
		return parent and parent.visible
	return false
	
# Função recursiva para procurar um joystick na árvore de cena
func find_joystick_recursive(node):
	if node is TouchScreenJoystick:
		return node
		
	for child in node.get_children():
		var result = find_joystick_recursive(child)
		if result:
			return result
			
	return null

# ====== SISTEMA DE INTERAÇÃO UNIVERSAL ======

# Função chamada quando o botão de interação é pressionado
func _on_botao_interacao_pressed() -> void:
	if pode_interagir and objeto_interagivel_atual:
		interagir_com_objeto(objeto_interagivel_atual)

# Verifica os objetos interagíveis no raio de alcance
func _process(_delta: float) -> void:
	# Verificar objetos interagíveis em cada frame para resposta imediata
	verificar_objetos_interagiveis()
	
	# Estas verificações podem ser feitas com menos frequência
	if Engine.get_frames_drawn() % 30 == 0:  # A cada 30 frames (meio segundo a 60fps)
		# Atualizar a visibilidade do joystick com base no estado atual do jogo
		update_joystick_visibility()
		
	# Nota: A lógica de animação idle foi movida para _physics_process 
	# para evitar conflitos de controle de animação

# Verifica se há objetos interagíveis próximos e atualiza o estado
func verificar_objetos_interagiveis() -> void:
	var proximo_objeto = encontrar_objeto_interagivel_proximo()
	
	if proximo_objeto != objeto_interagivel_atual:
		objeto_interagivel_atual = proximo_objeto
		atualizar_botao_interacao()

# Encontra o objeto interagível mais próximo dentro do raio de interação
func encontrar_objeto_interagivel_proximo():
	# Procura por qualquer objeto interagível
	var interactive_objects = []
	var root = get_tree().current_scene
	
	# Primeiro procura por objetos InteractiveObject
	_find_interactive_objects(root, interactive_objects)
	
	# Verifica se algum objeto interativo já registrou o jogador
	for obj in interactive_objects:
		if obj.player_in_range and obj.player_node == self:
			return obj
	
	# Compatibilidade com o sistema antigo
	if root:
		var quarto_casa = root.get_node_or_null("QuartoCasa")
		if quarto_casa:
			var musica_layer = quarto_casa.get_node_or_null("Musica")
			if musica_layer:
				# Calcular distância até o TileMapLayer Música
				var distancia = global_position.distance_to(musica_layer.global_position)
				if distancia <= raio_interacao:
					return musica_layer
	
	# Se não encontrou nenhum objeto interagível, retorna null
	return null
	
# Função recursiva para encontrar objetos interagíveis na cena
func _find_interactive_objects(node: Node, result: Array) -> void:
	if node is InteractiveObject:
		result.append(node)
	
	for child in node.get_children():
		_find_interactive_objects(child, result)

# Atualiza a visibilidade do botão de interação
func atualizar_botao_interacao() -> void:
	pode_interagir = objeto_interagivel_atual != null
	
	if botao_toque:
		# Sempre torna o botão visível quando há objeto interagível
		botao_toque.visible = pode_interagir
		
		if pode_interagir:
			# Configurar o texto do botão baseado no tipo de interação
			if objeto_interagivel_atual is InteractiveObject:
				# Primeiro usa o prompt personalizado definido no objeto
				botao_toque.text = objeto_interagivel_atual.get_interaction_prompt()
				
				# Adiciona efeito visual para destacar o botão
				_aplicar_efeito_destaque_botao()
			elif objeto_interagivel_atual.name.to_lower() in textos_interacao:
				# Usa o texto do dicionário se o nome do objeto corresponder a uma chave
				botao_toque.text = textos_interacao[objeto_interagivel_atual.name.to_lower()]
			else:
				# Usa a categoria baseada no nome do objeto, ou valor padrão
				var categoria = _identificar_categoria_objeto(objeto_interagivel_atual.name)
				botao_toque.text = textos_interacao.get(categoria, textos_interacao["default"])

# Interage com o objeto especificado
func interagir_com_objeto(objeto) -> void:
	# Tocar som de interação
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sfx("interact")
	
	# Verifica se é um objeto do novo sistema de interação
	if objeto is InteractiveObject:
		print("Interagindo com objeto: ", objeto.name)
		objeto.interact()
	# Compatibilidade com o sistema antigo
	elif objeto.name == "Musica":
		print("Tocando música na caixinha de som!")
		# Usar AudioManager para tocar música na caixinha de som
		if Engine.has_singleton("AudioManager"):
			var audio_manager = Engine.get_singleton("AudioManager")
			# Adicionar música específica para o objeto com redução de volume
			audio_manager.add_music("music_box", "res://assets/audio/songs/music_box.wav")
			audio_manager.play_music("music_box", 0.5, 0.5)
		
	# Emitir sinal para que outros objetos possam responder à interação
	interacao_realizada.emit(objeto)

func play_idle_in_direction(direction: Vector2) -> void:
	if not sprite:
		return
	
	# Determina qual animação de "parado" usar com base na última direção de movimento
	# Usamos o mesmo nome da animação, mas paramos no primeiro frame
	var animation_name = ""
	
	if abs(direction.x) > abs(direction.y):
		# Direção horizontal
		if direction.x > 0:
			animation_name = "direita"
		else:
			animation_name = "esquerda"
	else:
		# Direção vertical
		if direction.y > 0:
			animation_name = "baixo"
		else:
			animation_name = "cima"
	
	# Verifica se a animação existe
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		# Primeiro para qualquer animação em andamento
		sprite.stop()
		# Define a animação e define o frame para o inicial
		sprite.animation = animation_name
		sprite.frame = 0
		# Marca que o jogador está no estado idle para a próxima vez que se mover
		was_idle_last_frame = true
	else:
		# Fallback para animação padrão se a direção específica não existir
		sprite.stop()
		sprite.animation = "default"
		sprite.frame = 0
		# Marca que o jogador está no estado idle para a próxima vez que se mover
		was_idle_last_frame = true

# Verifica se o jogador está realmente em movimento baseado na velocidade
func is_actually_moving() -> bool:
	return velocity.length_squared() > 0.01  # Um pequeno valor para evitar imprecisões de ponto flutuante

# Registra o player para receber notificações de mudanças de estado do jogo
func register_for_game_state_changes() -> void:
	# Tenta obter referência ao Game (orquestrador)
	var game = get_node_or_null("/root/Game")
	if not game:
		print("Player: Não foi possível encontrar o orquestrador Game para registrar notificações de estado")
		return
		
	# Verifica se o game tem um sinal para notificar mudanças de estado
	if not game.has_signal("game_state_changed"):
		# Se não tiver o sinal, podemos criar a conexão manualmente no orquestrador
		print("Player: O orquestrador não possui sinal game_state_changed, usando verificação periódica")
	else:
		# Conecta ao sinal de mudança de estado se existir
		if not game.game_state_changed.is_connected(self.on_game_state_changed):
			game.game_state_changed.connect(self.on_game_state_changed)
			print("Player: Registrado para receber notificações de mudança de estado do jogo")

# Callback chamado quando o estado do jogo muda
func on_game_state_changed(_new_state) -> void:
	print("Player: Estado do jogo mudou, atualizando visibilidade do joystick")
	update_joystick_visibility()

# Função que identifica a categoria de um objeto baseado em seu nome
func _identificar_categoria_objeto(nome_objeto: String) -> String:
	nome_objeto = nome_objeto.to_lower()
	
	# Verifica palavras-chave no nome do objeto
	if "porta" in nome_objeto:
		if "trancada" in nome_objeto or "fechada" in nome_objeto:
			return "porta_trancada"
		return "porta"
	elif "musica" in nome_objeto or "radio" in nome_objeto or "som" in nome_objeto:
		return "musica"
	elif "computador" in nome_objeto or "pc" in nome_objeto or "laptop" in nome_objeto:
		return "computador"
	elif "alavanca" in nome_objeto or "botao" in nome_objeto or "switch" in nome_objeto:
		return "alavanca"
	elif "bau" in nome_objeto or "caixa" in nome_objeto or "container" in nome_objeto:
		return "bau"
	elif "item" in nome_objeto or "objeto" in nome_objeto or "coletavel" in nome_objeto:
		return "item"
	
	# Se não encontrou correspondência, retorna o tipo padrão
	return "default"

# Aplica efeito visual de destaque ao botão de interação
func _aplicar_efeito_destaque_botao() -> void:
	if not botao_toque:
		return
	
	# Cancela animações anteriores
	if botao_toque.has_meta("tween") and botao_toque.get_meta("tween") != null:
		var tween_antigo = botao_toque.get_meta("tween")
		if tween_antigo.is_valid() and tween_antigo.is_running():
			tween_antigo.kill()
	
	# Aplica efeito de pulsação sutil
	botao_toque.scale = Vector2(1.0, 1.0)
	var tween = create_tween()
	tween.set_loops()  # Loop infinito
	tween.tween_property(botao_toque, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(botao_toque, "scale", Vector2(1.0, 1.0), 0.5)
	
	# Armazena referência do tween para poder cancelá-lo depois
	botao_toque.set_meta("tween", tween)

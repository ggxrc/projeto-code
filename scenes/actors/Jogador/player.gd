extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var botao_toque = $CanvasLayer/BotaoToque

# Sistema de interação universal
var objeto_interagivel_atual = null
var pode_interagir = false
var raio_interacao = 100.0
signal interacao_realizada(objeto)

# Tempo de inatividade (em segundos) antes de mudar para animação "sleeping"
const IDLE_TIMEOUT = 5.0
var idle_timer = 0.0
var is_moving = false
var last_direction = Vector2.DOWN  # Armazena a última direção do movimento

func _ready() -> void:
	# Configura a animação padrão
	if sprite:
		sprite.play("idle")
		
	# Debug - Imprime as animações disponíveis
	if sprite and sprite.sprite_frames:
		print("Animações disponíveis: ", sprite.sprite_frames.get_animation_names())
		
	# Detecta se estamos em uma plataforma móvel e adiciona um joystick se necessário
	if OS.get_name() == "Android" or OS.get_name() == "iOS" or OS.has_feature("mobile"):
		add_virtual_joystick()
	
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
	
	if dir:
		# Aplica o movimento com base na entrada
		velocity = dir * 200
		
		# Atualiza a animação e a direção
		update_animation(dir)
		last_direction = dir  # Armazena a última direção para uso ao parar
		
		# Reset estado de inatividade
		is_moving = true
		
		# Enquanto se movimenta, verificar objetos interativos
		verificar_objetos_interagiveis()
		idle_timer = 0.0
	else:
		# Desacelera o movimento quando não há entrada
		velocity.x = move_toward(velocity.x, 0, 200)
		velocity.y = move_toward(velocity.y, 0, 200)
		
		# Verifica se acabou de parar
		if is_moving:
			# Acabou de parar de mover
			is_moving = false
			if sprite:
				# Quando para, muda para animação default
				sprite.play("default")
				# Reinicia o temporizador
				idle_timer = 0.0
		else:
			# Já estava parado, incrementa o temporizador de inatividade
			idle_timer += delta
			
			# Após 5 segundos, muda para a animação "idle"
			if idle_timer > 5.0 and sprite and sprite.animation != "idle" and sprite.animation != "sleeping":
				sprite.play("idle")
				
			# Após o tempo definido em IDLE_TIMEOUT, muda para "sleeping"
			elif idle_timer > IDLE_TIMEOUT and sprite and sprite.animation != "sleeping":
				sprite.play("sleeping")
	
	move_and_slide()
	
func update_animation(direction: Vector2) -> void:
	if not sprite:
		return
	
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
			
func _input(event: InputEvent) -> void:
	# Só processa input se o joystick estiver visível (controle habilitado)
	if is_joystick_visible() and (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
		if event.is_pressed():
			if sprite:
				# Se estava dormindo, volta para default
				if sprite.animation == "sleeping" or sprite.animation == "idle":
					sprite.play("default")
					idle_timer = 0.0
			
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

# Verifica se o joystick está visível e se não há diálogo ativo
func is_joystick_visible() -> bool:
	# Tenta usar o GameUtils singleton para verificar diálogos ativos
	if Engine.has_singleton("GameUtils"):
		var game_utils = Engine.get_singleton("GameUtils") 
		if game_utils.has_method("is_dialogue_active") and game_utils.is_dialogue_active():
			return false
	
	# Verifica a visibilidade do joystick
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

# Verifica os objetos interagíveis no raio de alcance e gerencia estado de inatividade
func _process(delta: float) -> void:
	# Lógica para animação idle
	if !is_moving:
		idle_timer += delta
		if idle_timer >= IDLE_TIMEOUT and sprite and sprite.animation != "sleeping":
			sprite.play("sleeping")
	else:
		idle_timer = 0.0
		if sprite and sprite.animation == "sleeping":
			sprite.play("idle")
	
	# Resetar flag de movimento a cada frame
	# (será definida como true em _physics_process se houver movimento)
	is_moving = false
	
	# Verificar objetos interagíveis próximos periodicamente
	if Engine.get_frames_drawn() % 30 == 0:  # A cada 30 frames (meio segundo a 60fps)
		verificar_objetos_interagiveis()

# Verifica se há objetos interagíveis próximos e atualiza o estado
func verificar_objetos_interagiveis() -> void:
	var proximo_objeto = encontrar_objeto_interagivel_proximo()
	
	if proximo_objeto != objeto_interagivel_atual:
		objeto_interagivel_atual = proximo_objeto
		atualizar_botao_interacao()

# Encontra o objeto interagível mais próximo dentro do raio de interação
func encontrar_objeto_interagivel_proximo():
	# Primeiro vamos procurar o TileMapLayer "Música"
	var root = get_tree().current_scene
	if root:
		var quarto_casa = root.get_node_or_null("QuartoCasa")
		if quarto_casa:
			var musica_layer = quarto_casa.get_node_or_null("Musica")
			if musica_layer:
				# Calcular distância até o TileMapLayer Música
				var distancia = global_position.distance_to(musica_layer.global_position)
				if distancia <= raio_interacao:
					return musica_layer
					
	return null

# Atualiza a visibilidade do botão de interação
func atualizar_botao_interacao() -> void:
	pode_interagir = objeto_interagivel_atual != null
	
	if botao_toque:
		botao_toque.visible = pode_interagir
		if pode_interagir:
			# Configurar o texto do botão baseado no tipo de interação
			if objeto_interagivel_atual.name == "Musica":
				botao_toque.text = "Tocar Música"
			else:
				botao_toque.text = "Interagir"

# Interage com o objeto especificado
func interagir_com_objeto(objeto) -> void:
	if objeto.name == "Musica":
		print("Tocando música na caixinha de som!")
		# Aqui você pode adicionar qualquer efeito visual ou sonoro
		# Por exemplo, tocar um som de música
		var audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		# audio_player.stream = load("res://assets/audio/musica.ogg")
		# audio_player.play()
		
	# Emitir sinal para que outros objetos possam responder à interação
	interacao_realizada.emit(objeto)

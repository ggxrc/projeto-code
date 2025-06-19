extends Control

# Referências aos botões
@onready var continuar_btn = $VBoxContainer/Continuar
@onready var configuracoes_btn = $VBoxContainer/Configuracoes
@onready var menu_principal_btn = $VBoxContainer/MenuPrincipal
@onready var sair_btn = $VBoxContainer/Sair

func _ready() -> void:
	# Conecta os sinais dos botões
	if continuar_btn and not continuar_btn.pressed.is_connected(_on_continuar_pressed):
		continuar_btn.pressed.connect(_on_continuar_pressed)
		
	if configuracoes_btn and not configuracoes_btn.pressed.is_connected(_on_configuracoes_pressed):
		configuracoes_btn.pressed.connect(_on_configuracoes_pressed)
	
	if menu_principal_btn and not menu_principal_btn.pressed.is_connected(_on_menu_principal_pressed):
		menu_principal_btn.pressed.connect(_on_menu_principal_pressed)
		
	if sair_btn and not sair_btn.pressed.is_connected(_on_sair_pressed):
		sair_btn.pressed.connect(_on_sair_pressed)

# Manipuladores de eventos para os botões
func _on_continuar_pressed() -> void:
	# Reproduz som de clique
	AudioManager.play_sfx("button_click")
	
	# Continua o jogo (saindo do modo de pausa)
	var orquestrador = _get_orquestrador()
	if orquestrador:
		orquestrador.resume_game()

func _on_configuracoes_pressed() -> void:
	# Reproduz som de clique
	AudioManager.play_sfx("button_click")
	
	# Abre o menu de configurações
	var orquestrador = _get_orquestrador()
	if orquestrador:
		orquestrador.open_options_from_pause()

func _on_menu_principal_pressed() -> void:
	# Reproduz som de clique
	AudioManager.play_sfx("button_click")
	
	# Volta ao menu principal
	var orquestrador = _get_orquestrador()
	if orquestrador:
		orquestrador.return_to_main_menu()

func _on_sair_pressed() -> void:
	# Reproduz som de clique
	AudioManager.play_sfx("button_click")
	
	# Sai do jogo
	var orquestrador = _get_orquestrador()
	if orquestrador:
		orquestrador.quit_game()

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

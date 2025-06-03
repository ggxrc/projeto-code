extends Node 

@onready var tela_inicial: Control = $TelaInicial 

var linhas_dialogo: Array[String] = [
	"Seja bem vindo(a), vejo que você é novo por aqui.",
	"Você pode achar que o começo é fácil, mas você sabe o que fazer?"
]
var indice_linha_atual: int = 0
var game_manager: Node = null 

func _ready() -> void:
	game_manager = get_node("/root/Game") 
	if not game_manager:
		printerr("Prologue.gd: Game.gd não encontrado em /root/Game!")

	if is_instance_valid(tela_inicial):
		if not tela_inicial.linha_exibida_completamente.is_connected(_avancar_dialogo):
			tela_inicial.linha_exibida_completamente.connect(_avancar_dialogo)
	else:
		printerr("Nó TelaInicial não encontrado em Prologue.gd no _ready!")

func _on_scene_activated() -> void:
	print("Prologue: Cena Ativada")
	if not is_instance_valid(tela_inicial):
		printerr("Nó TelaInicial não encontrado em Prologue.gd em _on_scene_activated!")
		return
	
	if not game_manager: 
		game_manager = get_node("/root/Game")
		if not game_manager:
			printerr("Prologue.gd: Game.gd ainda não encontrado! Não é possível verificar o estado da introdução.")
			_iniciar_sequencia_dialogo_completa()
			return

	if game_manager.prologo_introducao_concluida == true:
		print("Prologue: Introdução já concluída. Pulando diálogo da TelaInicial.")
		tela_inicial.visible = false 
		_prosseguir_apos_introducao_pulada()
	else:
		_iniciar_sequencia_dialogo_completa()

func _iniciar_sequencia_dialogo_completa() -> void:
	if not is_instance_valid(tela_inicial): return

	indice_linha_atual = 0
	tela_inicial.visible = true
	
	await tela_inicial.mostrar_fundo(0.5) 
	_exibir_linha_atual()

func _on_scene_deactivating() -> void:
	print("Prologue: Cena Desativada")
	if is_instance_valid(tela_inicial):
		tela_inicial.parar_e_limpar_linha_atual()
		if is_instance_valid(tela_inicial.fundo_preto):
			tela_inicial.fundo_preto.modulate.a = 0.0 
			tela_inicial.fundo_preto.visible = false 
		if is_instance_valid(tela_inicial.texto_label):
			tela_inicial.texto_label.modulate.a = 0.0

func _exibir_linha_atual() -> void:
	if not is_instance_valid(tela_inicial): return

	if indice_linha_atual < linhas_dialogo.size():
		tela_inicial.exibir_linha_dialogo(linhas_dialogo[indice_linha_atual])
	else:
		_finalizar_dialogo_da_introducao()

func _avancar_dialogo() -> void:
	indice_linha_atual += 1
	_exibir_linha_atual()

func _finalizar_dialogo_da_introducao() -> void:
	print("Prologue: Fim dos diálogos da introdução (TelaInicial).")
	
	if game_manager:
		game_manager.prologo_introducao_concluida = true
		print("Prologue: Flag 'prologo_introducao_concluida' definida como true.")

	if is_instance_valid(tela_inicial):
		await tela_inicial.esconder_fundo(1.0)
	
	_prosseguir_apos_introducao_pulada()

func _prosseguir_apos_introducao_pulada() -> void:
	print("Prologue: Avançando para gameplay...")
	if game_manager and game_manager.has_method("navigate_to_gameplay"):
		game_manager.navigate_to_gameplay("fade")
	else:
		printerr("Prologue: Não foi possível encontrar Game.gd ou o método navigate_to_gameplay.")

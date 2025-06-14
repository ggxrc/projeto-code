extends Button

# Este script apenas adiciona efeitos sonoros aos botões
# sem interferir na navegação implementada no menu_principal.gd

func _ready():
	print("Botão inicializado com script botao_menu_script.gd")
	
	# Conecta o sinal pressed diretamente, sem usar um método intermediário
	# para evitar conflitos com outros scripts
	pressed.connect(func():
		# Tocar som ao clicar
		AudioManager.play_sfx("button_click", 1.0, 1.0)
	)
	
	# Não interrompe o fluxo de sinais, permitindo que outros
	# manipuladores de botão funcionem normalmente

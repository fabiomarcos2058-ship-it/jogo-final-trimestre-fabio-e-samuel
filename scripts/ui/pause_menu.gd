extends CanvasLayer
## Menu de pausa (CanvasLayer). Esc ou P alterna a pausa durante o jogo.

var permitido: bool = true

@onready var botao_continuar: Button = $Centro/Caixa/BotaoContinuar
@onready var botao_menu: Button = $Centro/Caixa/BotaoMenu
@onready var botao_sair: Button = $Centro/Caixa/BotaoSair


func _ready() -> void:
	visible = false
	botao_continuar.pressed.connect(alternar)
	botao_menu.pressed.connect(Game.ir_para_menu)
	botao_sair.pressed.connect(Game.sair)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar") and (permitido or get_tree().paused):
		alternar()
		get_viewport().set_input_as_handled()


func alternar() -> void:
	var pausar := not get_tree().paused
	get_tree().paused = pausar
	visible = pausar
	if pausar:
		botao_continuar.grab_focus()

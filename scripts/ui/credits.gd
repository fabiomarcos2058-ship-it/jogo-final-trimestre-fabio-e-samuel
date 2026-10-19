extends Control
## Tela de créditos.

@onready var botao_voltar: Button = $Centro/Caixa/BotaoVoltar


func _ready() -> void:
	botao_voltar.pressed.connect(Game.ir_para_menu)
	botao_voltar.grab_focus()

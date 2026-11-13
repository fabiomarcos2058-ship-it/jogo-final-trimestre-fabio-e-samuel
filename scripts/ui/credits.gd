extends Control
## Tela de créditos.
##
## É aberta pelo botão Créditos do menu inicial (Game.ir_para_creditos()).
## Os textos ficam na própria cena (scenes/ui/credits.tscn); este script só
## cuida do botão que volta para o menu.

## Botão "Voltar ao menu", que leva de volta ao menu inicial (Game.ir_para_menu).
@onready var botao_voltar: Button = $Centro/Caixa/BotaoVoltar


## Liga o botão Voltar à troca de cena feita pelo autoload Game e coloca o
## foco nele.
func _ready() -> void:
	botao_voltar.pressed.connect(Game.ir_para_menu)
	# Com o foco no botão, dá para voltar ao menu sem usar o mouse.
	botao_voltar.grab_focus()

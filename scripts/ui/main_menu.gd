extends Control
## Menu inicial: Iniciar, Créditos e Sair.

@onready var botao_iniciar: Button = $Centro/Caixa/BotaoIniciar
@onready var botao_creditos: Button = $Centro/Caixa/BotaoCreditos
@onready var botao_sair: Button = $Centro/Caixa/BotaoSair
@onready var rotulo_recorde: Label = $Centro/Caixa/Recorde


func _ready() -> void:
	botao_iniciar.pressed.connect(Game.iniciar_jogo)
	botao_creditos.pressed.connect(Game.ir_para_creditos)
	botao_sair.pressed.connect(Game.sair)
	rotulo_recorde.text = "Recorde: %d pontos" % Game.recorde
	botao_iniciar.grab_focus()

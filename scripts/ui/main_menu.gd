extends Control
## Menu inicial: Iniciar, Créditos e Sair.
##
## É a primeira tela do jogo e também para onde Game.ir_para_menu() volta.
## Os botões só chamam funções do autoload Game, que faz a troca de cenas.

## Botão que começa um jogo novo (Game.iniciar_jogo).
@onready var botao_iniciar: Button = $Centro/Caixa/BotaoIniciar
## Botão que abre a tela de créditos (Game.ir_para_creditos).
@onready var botao_creditos: Button = $Centro/Caixa/BotaoCreditos
## Botão que fecha o jogo (Game.sair).
@onready var botao_sair: Button = $Centro/Caixa/BotaoSair
## Texto que mostra a maior pontuação já feita (Game.recorde).
@onready var rotulo_recorde: Label = $Centro/Caixa/Recorde


## Liga cada botão à sua ação no Game, mostra o recorde e coloca o foco
## no botão Iniciar.
func _ready() -> void:
	botao_iniciar.pressed.connect(Game.iniciar_jogo)
	botao_creditos.pressed.connect(Game.ir_para_creditos)
	botao_sair.pressed.connect(Game.sair)
	# O recorde é lido do arquivo user://recorde.cfg quando o Game inicia.
	rotulo_recorde.text = "Recorde: %d pontos" % Game.recorde
	# Com o foco no Iniciar, dá para usar o menu sem o mouse.
	botao_iniciar.grab_focus()

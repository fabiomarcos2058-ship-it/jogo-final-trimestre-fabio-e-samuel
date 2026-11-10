extends CanvasLayer
## Menu de pausa (CanvasLayer). Esc ou P alterna a pausa durante o jogo.
##
## A cena deste menu usa process_mode = Always (3), então ele continua
## recebendo entrada e respondendo aos botões mesmo com a árvore pausada.

## Se o jogador pode abrir a pausa. A fase (level.gd) coloca false ao congelar,
## quando a fase termina; mesmo assim, se o jogo já estiver pausado, ainda dá
## para despausar.
var permitido: bool = true

## Botão "Continuar": fecha o menu e despausa o jogo.
@onready var botao_continuar: Button = $Centro/Caixa/BotaoContinuar
## Botão que volta para o menu principal (Game.ir_para_menu).
@onready var botao_menu: Button = $Centro/Caixa/BotaoMenu
## Botão que fecha o jogo (Game.sair).
@onready var botao_sair: Button = $Centro/Caixa/BotaoSair


## Começa escondido e liga cada botão à sua ação.
func _ready() -> void:
	visible = false
	botao_continuar.pressed.connect(alternar)
	botao_menu.pressed.connect(Game.ir_para_menu)
	botao_sair.pressed.connect(Game.sair)


## Ao apertar a ação "pausar" (registrada no Game com Esc e P), alterna a pausa
## e marca o evento como tratado para que nenhum outro nó o receba.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar") and (permitido or get_tree().paused):
		alternar()
		get_viewport().set_input_as_handled()


## Inverte o estado de pausa da árvore e mostra/esconde o menu junto.
## Ao pausar, dá o foco ao botão "Continuar" para navegar pelo teclado.
func alternar() -> void:
	var pausar := not get_tree().paused
	get_tree().paused = pausar
	visible = pausar
	if pausar:
		botao_continuar.grab_focus()

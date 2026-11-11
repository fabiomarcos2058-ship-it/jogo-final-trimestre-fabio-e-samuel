extends Control
## Tela final: mostra vitória ou derrota e permite reiniciar ou voltar ao menu.
##
## É aberta por Game.terminar(), que antes guarda em Game se o jogador venceu
## (Game.venceu), o texto do motivo (Game.motivo) e atualiza o recorde.

## Título grande: "VITÓRIA!" (amarelo) ou "DERROTA" (vermelho).
@onready var titulo: Label = $Centro/Caixa/Titulo
## Texto explicando por que o jogo terminou (vem de Game.motivo).
@onready var motivo: Label = $Centro/Caixa/Motivo
## Linha com pontos, recorde e tempo total jogado.
@onready var estatisticas: Label = $Centro/Caixa/Estatisticas
## Caixa horizontal onde entram as imagens dos personagens do resultado.
@onready var personagens: HBoxContainer = $Centro/Caixa/Personagens
## Botão "jogar novamente": recomeça do início (Game.iniciar_jogo).
@onready var botao_novamente: Button = $Centro/Caixa/BotaoNovamente
## Botão que volta para o menu principal (Game.ir_para_menu).
@onready var botao_menu: Button = $Centro/Caixa/BotaoMenu


## Preenche a tela de acordo com o resultado guardado em Game e liga os botões.
func _ready() -> void:
	# Nomes dos sprites (assets/sprites/<nome>.png) que serão exibidos.
	var quem: Array[String]
	if Game.venceu:
		titulo.text = "VITÓRIA!"
		titulo.add_theme_color_override("font_color", Color("ffe066"))
		# Na vitória aparecem as cinco irmãs.
		quem = ["ichika", "nino", "miku", "yotsuba", "itsuki"]
	else:
		titulo.text = "DERROTA"
		titulo.add_theme_color_override("font_color", Color("ff6b6b"))
		# Na derrota aparece só o Fuutarou.
		quem = ["fuutarou"]
	motivo.text = Game.motivo
	# Tempo somado de todas as fases jogadas, em segundos inteiros,
	# mostrado no formato minutos:segundos.
	var total := int(Game.tempo_total)
	estatisticas.text = "Pontos: %d    Recorde: %d    Tempo jogado: %d:%02d" % [
		Game.pontos, Game.recorde, total / 60, total % 60]
	# Cria uma imagem 96x96 para cada personagem, mantendo a proporção.
	for nome in quem:
		var t := TextureRect.new()
		t.texture = load("res://assets/sprites/%s.png" % nome)
		t.custom_minimum_size = Vector2(96, 96)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		personagens.add_child(t)
	botao_novamente.pressed.connect(Game.iniciar_jogo)
	botao_menu.pressed.connect(Game.ir_para_menu)
	# Foco inicial no botão de jogar novamente, para usar só o teclado.
	botao_novamente.grab_focus()

extends Control
## Tela final: mostra vitória ou derrota e permite reiniciar ou voltar ao menu.

@onready var titulo: Label = $Centro/Caixa/Titulo
@onready var motivo: Label = $Centro/Caixa/Motivo
@onready var estatisticas: Label = $Centro/Caixa/Estatisticas
@onready var personagens: HBoxContainer = $Centro/Caixa/Personagens
@onready var botao_novamente: Button = $Centro/Caixa/BotaoNovamente
@onready var botao_menu: Button = $Centro/Caixa/BotaoMenu


func _ready() -> void:
	var quem: Array[String]
	if Game.venceu:
		titulo.text = "VITÓRIA!"
		titulo.add_theme_color_override("font_color", Color("ffe066"))
		quem = ["ichika", "nino", "miku", "yotsuba", "itsuki"]
	else:
		titulo.text = "DERROTA"
		titulo.add_theme_color_override("font_color", Color("ff6b6b"))
		quem = ["fuutarou"]
	motivo.text = Game.motivo
	var total := int(Game.tempo_total)
	estatisticas.text = "Pontos: %d    Recorde: %d    Tempo jogado: %d:%02d" % [
		Game.pontos, Game.recorde, total / 60, total % 60]
	for nome in quem:
		var t := TextureRect.new()
		t.texture = load("res://assets/sprites/%s.png" % nome)
		t.custom_minimum_size = Vector2(96, 96)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		personagens.add_child(t)
	botao_novamente.pressed.connect(Game.iniciar_jogo)
	botao_menu.pressed.connect(Game.ir_para_menu)
	botao_novamente.grab_focus()

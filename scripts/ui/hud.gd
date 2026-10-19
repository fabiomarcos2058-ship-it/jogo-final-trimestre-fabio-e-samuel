extends CanvasLayer
## Interface do jogo: vidas, pontos, tempo, provas coletadas e mensagens.

@onready var rotulo_fase: Label = $Barra/Fase
@onready var rotulo_vidas: Label = $Barra/Vidas
@onready var rotulo_pontos: Label = $Barra/Pontos
@onready var rotulo_tempo: Label = $Barra/Tempo
@onready var lista_provas: HBoxContainer = $ListaProvas
@onready var mensagem: Label = $Mensagem

var _rotulos_provas: Array[Label] = []
var _tween_msg: Tween


func _ready() -> void:
	for i in Game.TOTAL_PROVAS:
		var l := Label.new()
		l.text = Game.NOMES_IRMAS[i]
		l.add_theme_font_size_override("font_size", 16)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.add_theme_constant_override("outline_size", 5)
		l.modulate = Color(Game.CORES_IRMAS[i], 0.35)
		lista_provas.add_child(l)
		_rotulos_provas.append(l)
	mensagem.modulate.a = 0.0


func definir_fase(nome: String) -> void:
	rotulo_fase.text = nome


func atualizar_vidas(v: int) -> void:
	rotulo_vidas.text = "Vidas: %d" % v


func atualizar_pontos(p: int) -> void:
	rotulo_pontos.text = "Pontos: %d" % p


func atualizar_tempo(t: float) -> void:
	var s := maxi(0, int(t))
	rotulo_tempo.text = "Tempo: %d:%02d" % [s / 60, s % 60]
	rotulo_tempo.modulate = Color(1.0, 0.45, 0.45) if s <= 20 else Color.WHITE


func marcar_prova(indice: int) -> void:
	var l := _rotulos_provas[indice]
	l.modulate = Color(Game.CORES_IRMAS[indice], 1.0)
	l.text = "%s OK" % Game.NOMES_IRMAS[indice]


func mostrar_mensagem(texto: String, duracao: float = 2.5) -> void:
	mensagem.text = texto
	if _tween_msg != null:
		_tween_msg.kill()
	mensagem.modulate.a = 1.0
	_tween_msg = create_tween()
	_tween_msg.tween_interval(duracao)
	_tween_msg.tween_property(mensagem, "modulate:a", 0.0, 0.6)

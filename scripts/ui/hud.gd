extends CanvasLayer
## Interface do jogo: vidas, pontos, tempo, provas coletadas e mensagens.

## Rótulo com o nome da fase atual (na barra superior).
@onready var rotulo_fase: Label = $Barra/Fase
## Rótulo que mostra as vidas restantes.
@onready var rotulo_vidas: Label = $Barra/Vidas
## Rótulo que mostra a pontuação.
@onready var rotulo_pontos: Label = $Barra/Pontos
## Rótulo que mostra o tempo restante no formato minutos:segundos.
@onready var rotulo_tempo: Label = $Barra/Tempo
## Container onde ficam os rótulos das provas de cada irmã.
@onready var lista_provas: HBoxContainer = $ListaProvas
## Rótulo central usado para avisos temporários.
@onready var mensagem: Label = $Mensagem

## Rótulos criados em _ready(), um por prova, na mesma ordem de Game.NOMES_IRMAS.
var _rotulos_provas: Array[Label] = []
## Tween atual do desaparecimento da mensagem (guardado para poder cancelá-lo).
var _tween_msg: Tween


## Cria um rótulo para cada prova (com o nome e a cor da irmã, ainda
## semitransparente porque não foi coletada) e esconde a mensagem central.
func _ready() -> void:
	for i in Game.TOTAL_PROVAS:
		var l := Label.new()
		l.text = Game.NOMES_IRMAS[i]
		l.add_theme_font_size_override("font_size", 16)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.add_theme_constant_override("outline_size", 5)
		# Alfa 0.35 indica que a prova ainda não foi recuperada.
		l.modulate = Color(Game.CORES_IRMAS[i], 0.35)
		lista_provas.add_child(l)
		_rotulos_provas.append(l)
	mensagem.modulate.a = 0.0


## Mostra o nome da fase na barra superior.
func definir_fase(nome: String) -> void:
	rotulo_fase.text = nome


## Atualiza o texto de vidas com o valor [param v].
func atualizar_vidas(v: int) -> void:
	rotulo_vidas.text = "Vidas: %d" % v


## Atualiza o texto de pontos com o valor [param p].
func atualizar_pontos(p: int) -> void:
	rotulo_pontos.text = "Pontos: %d" % p


## Mostra o tempo [param t] (em segundos) como "m:ss", nunca abaixo de zero.
## Com 20 segundos ou menos o texto fica avermelhado como alerta.
func atualizar_tempo(t: float) -> void:
	var s := maxi(0, int(t))
	rotulo_tempo.text = "Tempo: %d:%02d" % [s / 60, s % 60]
	rotulo_tempo.modulate = Color(1.0, 0.45, 0.45) if s <= 20 else Color.WHITE


## Marca a prova de número [param indice] como coletada: deixa o rótulo
## totalmente opaco e acrescenta "OK" ao nome da irmã.
func marcar_prova(indice: int) -> void:
	var l := _rotulos_provas[indice]
	l.modulate = Color(Game.CORES_IRMAS[indice], 1.0)
	l.text = "%s OK" % Game.NOMES_IRMAS[indice]


## Exibe [param texto] no centro da tela por [param duracao] segundos e depois
## o faz sumir em 0,6 s. Uma nova mensagem cancela o sumiço da anterior.
func mostrar_mensagem(texto: String, duracao: float = 2.5) -> void:
	mensagem.text = texto
	if _tween_msg != null:
		_tween_msg.kill()
	mensagem.modulate.a = 1.0
	_tween_msg = create_tween()
	_tween_msg.tween_interval(duracao)
	_tween_msg.tween_property(mensagem, "modulate:a", 0.0, 0.6)

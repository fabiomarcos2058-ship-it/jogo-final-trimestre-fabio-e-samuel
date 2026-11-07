class_name Coletavel
extends Area2D
## Item coletável: PROVA (objetivo), NOTA (pontos) e SODA (recupera 1 vida).
##
## Flutua para cima e para baixo e, quando o jogador encosta nele, aplica o
## efeito do seu [member tipo], emite [signal coletado] e some da fase.

## Emitido ao ser pego pelo jogador, com o tipo do item e o índice da prova
## (a fase, em level.gd, escuta este sinal).
signal coletado(tipo: int, indice: int)

## Tipos de item: PROVA de uma das irmãs, NOTA (vale pontos) e SODA (cura).
enum Tipo { PROVA, NOTA, SODA }

## Qual dos tipos de [enum Tipo] este item é.
@export var tipo: Tipo = Tipo.NOTA
## Índice da irmã dona da prova (posição em Game.NOMES_IRMAS e Game.CORES_IRMAS).
## Só é usado quando o [member tipo] é PROVA.
@export var indice_prova: int = 0

## Sprite do item, que recebe a cor da irmã e a animação de flutuar.
@onready var sprite: Sprite2D = $Sprite


## Conecta a detecção do jogador, colore a prova com a cor da irmã (clareada
## 50% em direção ao branco), mostra o nome dela no rótulo "Nome" (se existir)
## e inicia um tween em loop que faz o sprite flutuar 4 pixels para cima e para baixo.
func _ready() -> void:
	body_entered.connect(_ao_entrar)
	if tipo == Tipo.PROVA:
		sprite.modulate = Game.CORES_IRMAS[indice_prova].lerp(Color.WHITE, 0.5)
		var nome := get_node_or_null("Nome") as Label
		if nome != null:
			nome.text = Game.NOMES_IRMAS[indice_prova]
	var t := create_tween().set_loops()
	t.tween_property(sprite, "position:y", -4.0, 0.7).set_trans(Tween.TRANS_SINE)
	t.tween_property(sprite, "position:y", 4.0, 0.7).set_trans(Tween.TRANS_SINE)


## Chamada quando um corpo entra na área. Ignora quem não está no grupo "jogador".
## PROVA: registra a prova e dá 200 pontos. NOTA: dá 100 pontos.
## SODA: cura 1 vida; se a vida já estiver cheia, dá 50 pontos no lugar.
## Depois toca o som, emite [signal coletado] e remove o item.
func _ao_entrar(corpo: Node2D) -> void:
	if not corpo.is_in_group("jogador"):
		return
	if tipo == Tipo.PROVA:
		Game.coletar_prova(indice_prova)
		Game.adicionar_pontos(200)
		Game.sfx("prova")
	elif tipo == Tipo.NOTA:
		Game.adicionar_pontos(100)
		Game.sfx("coleta")
	else:
		if not corpo.curar(1):
			Game.adicionar_pontos(50)
		Game.sfx("coleta")
	coletado.emit(tipo, indice_prova)
	queue_free()

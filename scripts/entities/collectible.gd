class_name Coletavel
extends Area2D
## Item coletável: PROVA (objetivo), NOTA (pontos) e SODA (recupera 1 vida).

signal coletado(tipo: int, indice: int)

enum Tipo { PROVA, NOTA, SODA }

@export var tipo: Tipo = Tipo.NOTA
@export var indice_prova: int = 0

@onready var sprite: Sprite2D = $Sprite


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

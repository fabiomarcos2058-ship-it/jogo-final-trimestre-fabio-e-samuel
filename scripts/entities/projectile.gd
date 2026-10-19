class_name Projetil
extends Area2D
## Livro arremessado pelo Fuutarou. Atordoa a primeira irmã que acertar.

@export var velocidade: float = 380.0
@export var alcance: float = 420.0

var direcao: Vector2 = Vector2.RIGHT
var _percorrido: float = 0.0


func _ready() -> void:
	body_entered.connect(_ao_colidir)


func _physics_process(delta: float) -> void:
	var passo := direcao * velocidade * delta
	position += passo
	rotation += 12.0 * delta
	_percorrido += passo.length()
	if _percorrido >= alcance:
		queue_free()


func _ao_colidir(corpo: Node) -> void:
	if corpo.has_method("atordoar"):
		corpo.atordoar(3.0)
		Game.sfx("acerto")
	queue_free()

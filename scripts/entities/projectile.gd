class_name Projetil
extends Area2D
## Livro arremessado pelo Fuutarou. Atordoa a primeira irmã que acertar.
##
## É criado pelo script do jogador (a partir de projectile.tscn), que define a
## [member direcao] antes de colocá-lo na fase. O livro anda em linha reta,
## girando, até bater em algum corpo ou percorrer o [member alcance].

## Velocidade de deslocamento do livro, em pixels por segundo.
@export var velocidade: float = 380.0
## Distância máxima (em pixels) que o livro percorre antes de sumir.
@export var alcance: float = 420.0

## Direção do movimento. O jogador a preenche com a direção para onde está olhando.
var direcao: Vector2 = Vector2.RIGHT
## Distância já percorrida desde que o livro foi criado (comparada com [member alcance]).
var _percorrido: float = 0.0


## Conecta o sinal de colisão com corpos à função [method _ao_colidir].
func _ready() -> void:
	body_entered.connect(_ao_colidir)


## A cada quadro de física: move o livro na [member direcao], faz ele girar
## (12 radianos por segundo, só visual) e o remove ao atingir o [member alcance].
func _physics_process(delta: float) -> void:
	var passo := direcao * velocidade * delta
	position += passo
	rotation += 12.0 * delta
	_percorrido += passo.length()
	if _percorrido >= alcance:
		queue_free()


## Chamada quando o livro encosta em um corpo. Se o corpo puder ser atordoado
## (tem o método atordoar, como as irmãs), atordoa por 3 segundos e toca o som
## de acerto. Em qualquer caso, o livro é destruído.
func _ao_colidir(corpo: Node) -> void:
	if corpo.has_method("atordoar"):
		corpo.atordoar(3.0)
		Game.sfx("acerto")
	queue_free()

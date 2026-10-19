class_name Inimigo
extends CharacterBody2D
## Irmã fugindo dos estudos. PATRULHA: anda e desvia das paredes.
## PERSEGUE: patrulha, mas corre atrás do jogador quando o enxerga.
## Um livro acertado deixa a irmã "estudando" (atordoada) por alguns segundos.

enum Tipo { PATRULHA, PERSEGUE }

@export var tipo: Tipo = Tipo.PATRULHA
@export var velocidade: float = 70.0
@export var velocidade_perseguicao: float = 105.0
@export var raio_visao: float = 190.0

var fator_dificuldade: float = 1.0
var atordoado: float = 0.0

var _dir: Vector2 = Vector2.RIGHT
var _troca: float = 2.0
var _tempo: float = 0.0
var _perseguindo: bool = false
var _jogador: Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var area_dano: Area2D = $AreaDano
@onready var aviso: Label = $Aviso


func _ready() -> void:
	add_to_group("inimigos")
	_jogador = get_tree().get_first_node_in_group("jogador")
	_dir = _direcao_aleatoria()
	_troca = randf_range(1.5, 3.5)
	_tempo = randf() * 10.0
	aviso.visible = false


func _physics_process(delta: float) -> void:
	_tempo += delta
	if atordoado > 0.0:
		atordoado -= delta
		velocity = Vector2.ZERO
		if atordoado <= 0.0:
			_recuperar()
		return

	_decidir_movimento(delta)
	move_and_slide()
	if get_slide_collision_count() > 0 and not _perseguindo:
		_dir = _direcao_aleatoria(_dir)
		_troca = randf_range(1.5, 3.5)

	sprite.position.y = sin(_tempo * 14.0) * 2.0
	if absf(velocity.x) > 5.0:
		sprite.flip_h = velocity.x < 0.0
	_causar_dano()


func _decidir_movimento(delta: float) -> void:
	_perseguindo = false
	if tipo == Tipo.PERSEGUE and is_instance_valid(_jogador) and _ve_jogador():
		_perseguindo = true
		var alvo := global_position.direction_to(_jogador.global_position)
		velocity = alvo * velocidade_perseguicao * fator_dificuldade
		return
	_troca -= delta
	if _troca <= 0.0:
		_dir = _direcao_aleatoria(_dir)
		_troca = randf_range(1.5, 3.5)
	velocity = _dir * velocidade * fator_dificuldade


func _ve_jogador() -> bool:
	if global_position.distance_to(_jogador.global_position) > raio_visao:
		return false
	var consulta := PhysicsRayQueryParameters2D.create(global_position, _jogador.global_position, 1)
	return get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()


func _direcao_aleatoria(excluir: Vector2 = Vector2.ZERO) -> Vector2:
	var opcoes: Array[Vector2] = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
	opcoes.erase(excluir)
	return opcoes.pick_random()


func _causar_dano() -> void:
	for corpo in area_dano.get_overlapping_bodies():
		if corpo.has_method("tomar_dano"):
			corpo.tomar_dano(global_position)


func atordoar(segundos: float = 3.0) -> void:
	if atordoado <= 0.0:
		Game.adicionar_pontos(50)
	atordoado = segundos
	sprite.modulate = Color(0.55, 0.7, 1.0)
	aviso.visible = true


func _recuperar() -> void:
	sprite.modulate = Color.WHITE
	aviso.visible = false

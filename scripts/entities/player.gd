class_name Jogador
extends CharacterBody2D
## Fuutarou Uesugi: movimento top-down, arremesso de livros e sistema de vidas.

signal vida_mudou(vidas: int)
signal morreu

const CENA_LIVRO := preload("res://scenes/entities/projectile.tscn")

@export var velocidade: float = 175.0
@export var recarga_tiro: float = 0.35
@export var tempo_invulneravel: float = 1.5

var vidas: int = 3
var direcao_olhar: Vector2 = Vector2.DOWN
var congelado: bool = false
var container_projeteis: Node

var _invulneravel: float = 0.0
var _recarga: float = 0.0
var _tempo: float = 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera


func _ready() -> void:
	add_to_group("jogador")
	vidas = Game.vidas


func _physics_process(delta: float) -> void:
	_recarga = maxf(0.0, _recarga - delta)
	if _invulneravel > 0.0:
		_invulneravel -= delta
		sprite.modulate.a = 0.35 if int(_invulneravel * 12.0) % 2 == 0 else 1.0
		if _invulneravel <= 0.0:
			sprite.modulate.a = 1.0
	if congelado:
		velocity = Vector2.ZERO
		return

	var entrada := Input.get_vector("esquerda", "direita", "cima", "baixo")
	velocity = entrada * velocidade
	if entrada != Vector2.ZERO:
		direcao_olhar = entrada.normalized()
		_tempo += delta
		sprite.position.y = sin(_tempo * 16.0) * 2.0
		if absf(entrada.x) > 0.1:
			sprite.flip_h = entrada.x < 0.0
	else:
		sprite.position.y = 0.0
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if congelado or not event.is_action_pressed("atirar"):
		return
	var dir := direcao_olhar
	if event is InputEventMouseButton:
		var alvo := get_global_mouse_position() - global_position
		if alvo.length() > 4.0:
			dir = alvo.normalized()
	atirar(dir)


func atirar(dir: Vector2) -> void:
	if _recarga > 0.0:
		return
	_recarga = recarga_tiro
	var livro := CENA_LIVRO.instantiate()
	livro.direcao = dir
	var pai: Node = container_projeteis if container_projeteis != null else get_parent()
	pai.add_child(livro)  # instância dinâmica em tempo de execução
	livro.global_position = global_position + dir * 16.0
	Game.sfx("tiro", -6.0)


func tomar_dano(_origem: Vector2 = Vector2.ZERO) -> void:
	if _invulneravel > 0.0 or congelado:
		return
	vidas -= 1
	Game.vidas = vidas
	_invulneravel = tempo_invulneravel
	Game.sfx("dano")
	vida_mudou.emit(vidas)
	if vidas <= 0:
		congelado = true
		morreu.emit()


func curar(qtd: int = 1) -> bool:
	if vidas >= Game.VIDAS_MAX:
		return false
	vidas = mini(vidas + qtd, Game.VIDAS_MAX)
	Game.vidas = vidas
	vida_mudou.emit(vidas)
	return true

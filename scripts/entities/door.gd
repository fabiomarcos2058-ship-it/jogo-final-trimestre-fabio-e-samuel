class_name PortaSaida
extends Area2D
## Porta da sala de estudos: só abre depois de coletar as 5 provas.

signal jogador_entrou(aberta: bool)

const TEX_FECHADA := preload("res://assets/sprites/porta_fechada.png")
const TEX_ABERTA := preload("res://assets/sprites/porta_aberta.png")

var aberta: bool = false

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	sprite.texture = TEX_FECHADA
	body_entered.connect(_ao_entrar)


func abrir() -> void:
	if aberta:
		return
	aberta = true
	sprite.texture = TEX_ABERTA
	Game.sfx("porta")
	for corpo in get_overlapping_bodies():  # jogador já estava em cima da porta
		_ao_entrar(corpo)


func _ao_entrar(corpo: Node2D) -> void:
	if corpo.is_in_group("jogador"):
		jogador_entrou.emit(aberta)

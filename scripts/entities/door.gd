class_name PortaSaida
extends Area2D
## Porta da sala de estudos: só abre depois de coletar as 5 provas.
##
## Começa fechada. A fase (level.gd) chama [method abrir] quando todas as
## provas são coletadas e escuta [signal jogador_entrou] para decidir entre
## vencer a fase ou avisar que a porta ainda está trancada.

## Emitido quando o jogador encosta na porta, informando se ela já está aberta.
signal jogador_entrou(aberta: bool)

## Textura mostrada enquanto a porta está trancada.
const TEX_FECHADA := preload("res://assets/sprites/porta_fechada.png")
## Textura mostrada depois que a porta é aberta.
const TEX_ABERTA := preload("res://assets/sprites/porta_aberta.png")

## Se a porta já foi aberta (todas as provas coletadas).
var aberta: bool = false

## Sprite que troca entre a textura fechada e a aberta.
@onready var sprite: Sprite2D = $Sprite


## Mostra a porta fechada e conecta a detecção de corpos que entram na área.
func _ready() -> void:
	sprite.texture = TEX_FECHADA
	body_entered.connect(_ao_entrar)


## Abre a porta (só na primeira chamada): troca a textura, toca o som "porta"
## e, se o jogador já estiver em cima dela, trata a entrada na hora.
func abrir() -> void:
	if aberta:
		return
	aberta = true
	sprite.texture = TEX_ABERTA
	Game.sfx("porta")
	for corpo in get_overlapping_bodies():  # jogador já estava em cima da porta
		_ao_entrar(corpo)


## Chamada quando um corpo entra na área. Se for do grupo "jogador",
## emite [signal jogador_entrou] com o estado atual da porta.
func _ao_entrar(corpo: Node2D) -> void:
	if corpo.is_in_group("jogador"):
		jogador_entrou.emit(aberta)

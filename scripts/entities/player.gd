class_name Jogador
extends CharacterBody2D
## Fuutarou Uesugi: movimento top-down, arremesso de livros e sistema de vidas.

## Emitido sempre que o número de vidas muda (dano ou cura), com o valor novo.
signal vida_mudou(vidas: int)
## Emitido uma vez quando as vidas chegam a zero.
signal morreu

## Cena do livro arremessado pelo jogador (projétil).
const CENA_LIVRO := preload("res://scenes/entities/projectile.tscn")

## Velocidade de movimento, em pixels por segundo.
@export var velocidade: float = 175.0
## Tempo mínimo (em segundos) entre dois arremessos de livro.
@export var recarga_tiro: float = 0.35
## Duração (em segundos) da invulnerabilidade depois de tomar dano.
@export var tempo_invulneravel: float = 1.5

## Vidas atuais; no início é copiado de [code]Game.vidas[/code].
var vidas: int = 3
## Última direção em que o jogador andou; usada para atirar pelo teclado.
var direcao_olhar: Vector2 = Vector2.DOWN
## Quando verdadeiro, o jogador não se move nem atira (ex.: depois de morrer).
var congelado: bool = false
## Nó onde os livros são adicionados; se for nulo, usa o nó pai do jogador.
var container_projeteis: Node

## Tempo restante de invulnerabilidade (0 = pode tomar dano).
var _invulneravel: float = 0.0
## Tempo restante até poder atirar de novo.
var _recarga: float = 0.0
## Tempo acumulado andando; controla o balanço do sprite ao caminhar.
var _tempo: float = 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera


## Entra no grupo "jogador" (para os outros nós o encontrarem) e
## carrega as vidas guardadas no autoload Game.
func _ready() -> void:
	add_to_group("jogador")
	vidas = Game.vidas


## A cada quadro de física: atualiza a recarga, faz o sprite piscar durante
## a invulnerabilidade, lê o movimento (WASD/setas) e move o personagem.
func _physics_process(delta: float) -> void:
	_recarga = maxf(0.0, _recarga - delta)
	# Pisca o sprite alternando a transparência enquanto está invulnerável.
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
		# Balanço vertical do sprite para simular os passos.
		_tempo += delta
		sprite.position.y = sin(_tempo * 16.0) * 2.0
		# Vira o sprite para o lado em que está andando.
		if absf(entrada.x) > 0.1:
			sprite.flip_h = entrada.x < 0.0
	else:
		sprite.position.y = 0.0
	move_and_slide()


## Trata a ação "atirar": com o mouse, mira na posição do cursor;
## pelo teclado, atira na direção em que o jogador está olhando.
func _unhandled_input(event: InputEvent) -> void:
	if congelado or not event.is_action_pressed("atirar"):
		return
	var dir := direcao_olhar
	if event is InputEventMouseButton:
		var alvo := get_global_mouse_position() - global_position
		# Ignora cliques muito em cima do jogador (direção indefinida).
		if alvo.length() > 4.0:
			dir = alvo.normalized()
	atirar(dir)


## Arremessa um livro na direção [param dir], respeitando a recarga.
## O livro nasce um pouco à frente do jogador e toca o som "tiro".
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


## Tira 1 vida, a menos que o jogador esteja invulnerável ou congelado.
## Ativa a invulnerabilidade, avisa a HUD pelo sinal [signal vida_mudou]
## e emite [signal morreu] quando as vidas acabam.
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


## Recupera [param qtd] vidas sem passar de [code]Game.VIDAS_MAX[/code].
## Retorna [code]false[/code] se as vidas já estavam no máximo (nada muda).
func curar(qtd: int = 1) -> bool:
	if vidas >= Game.VIDAS_MAX:
		return false
	vidas = mini(vidas + qtd, Game.VIDAS_MAX)
	Game.vidas = vidas
	vida_mudou.emit(vidas)
	return true

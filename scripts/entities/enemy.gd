class_name Inimigo
extends CharacterBody2D
## Irmã fugindo dos estudos. PATRULHA: anda e desvia das paredes.
## PERSEGUE: patrulha, mas corre atrás do jogador quando o enxerga.
## Um livro acertado deixa a irmã "estudando" (atordoada) por alguns segundos.

## Comportamento do inimigo: PATRULHA só anda; PERSEGUE também corre atrás do jogador.
enum Tipo { PATRULHA, PERSEGUE }

## Qual comportamento esta irmã usa (definido na cena ou pelo nível).
@export var tipo: Tipo = Tipo.PATRULHA
## Velocidade de patrulha, em pixels por segundo.
@export var velocidade: float = 70.0
## Velocidade ao perseguir o jogador, em pixels por segundo.
@export var velocidade_perseguicao: float = 105.0
## Distância máxima (em pixels) em que a irmã consegue enxergar o jogador.
@export var raio_visao: float = 190.0

## Multiplicador das velocidades; o nível aumenta com o tempo e a fase.
var fator_dificuldade: float = 1.0
## Segundos restantes de atordoamento (0 = livre para andar).
var atordoado: float = 0.0

## Direção atual da patrulha (direita, esquerda, cima ou baixo).
var _dir: Vector2 = Vector2.RIGHT
## Contagem regressiva, em segundos, até sortear uma nova direção.
var _troca: float = 2.0
## Tempo acumulado; usado na animação de "quicar" do sprite.
var _tempo: float = 0.0
## Verdadeiro no quadro em que a irmã está correndo atrás do jogador.
var _perseguindo: bool = false
## Referência ao jogador (primeiro nó do grupo "jogador").
var _jogador: Node2D

## Sprite da irmã (balança, vira e muda de cor ao ser atordoada).
@onready var sprite: Sprite2D = $Sprite
## Área que causa dano ao jogador quando ele encosta.
@onready var area_dano: Area2D = $AreaDano
## Texto mostrado sobre a irmã enquanto ela está atordoada.
@onready var aviso: Label = $Aviso


## Entra no grupo "inimigos", acha o jogador e sorteia direção, troca e fase da animação.
func _ready() -> void:
	add_to_group("inimigos")
	_jogador = get_tree().get_first_node_in_group("jogador")
	_dir = _direcao_aleatoria()
	_troca = randf_range(1.5, 3.5)
	_tempo = randf() * 10.0
	aviso.visible = false


## A cada quadro de física: conta o atordoamento ou se move, desvia de paredes,
## anima o sprite e tenta causar dano.
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
	# Bateu em algo durante a patrulha: muda de direção.
	if get_slide_collision_count() > 0 and not _perseguindo:
		_dir = _direcao_aleatoria(_dir)
		_troca = randf_range(1.5, 3.5)

	# Pequeno balanço vertical para parecer que está andando.
	sprite.position.y = sin(_tempo * 14.0) * 2.0
	if absf(velocity.x) > 5.0:
		sprite.flip_h = velocity.x < 0.0
	_causar_dano()


## Define [member velocity]: persegue o jogador se for do tipo PERSEGUE e o enxergar;
## senão, patrulha trocando de direção quando [member _troca] acaba.
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


## Retorna verdadeiro se o jogador está dentro de [member raio_visao] e nenhum
## obstáculo (camada de colisão 1) bloqueia a linha de visão.
func _ve_jogador() -> bool:
	if global_position.distance_to(_jogador.global_position) > raio_visao:
		return false
	var consulta := PhysicsRayQueryParameters2D.create(global_position, _jogador.global_position, 1)
	return get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()


## Sorteia uma das quatro direções cardeais, sem repetir [param excluir].
func _direcao_aleatoria(excluir: Vector2 = Vector2.ZERO) -> Vector2:
	var opcoes: Array[Vector2] = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
	opcoes.erase(excluir)
	return opcoes.pick_random()


## Chama [code]tomar_dano[/code] em todo corpo que estiver dentro da [member area_dano].
func _causar_dano() -> void:
	for corpo in area_dano.get_overlapping_bodies():
		if corpo.has_method("tomar_dano"):
			corpo.tomar_dano(global_position)


## Deixa a irmã "estudando" por [param segundos]. Chamada pelo livro (projétil).
## Só dá 50 pontos se ela ainda não estava atordoada.
func atordoar(segundos: float = 3.0) -> void:
	if atordoado <= 0.0:
		Game.adicionar_pontos(50)
	atordoado = segundos
	sprite.modulate = Color(0.55, 0.7, 1.0)
	aviso.visible = true


## Volta a cor normal e esconde o aviso quando o atordoamento acaba.
func _recuperar() -> void:
	sprite.modulate = Color.WHITE
	aviso.visible = false

extends Node2D
## Cena principal do jogo. Monta a fase a partir do mapa ASCII de LevelData,
## controla o tempo, a dificuldade progressiva, os spawns dinâmicos e o fim da fase.

## Tamanho de cada célula do mapa (tile), em pixels.
const TAM := 32
## Caracteres do mapa que viram parede, ligados às coordenadas do tile no atlas:
## # parede, B estante e T mesa.
const PAREDES := {"#": Vector2i(2, 0), "B": Vector2i(3, 0), "T": Vector2i(4, 0)}
## Polígono de colisão (quadrado de 32x32 centrado) usado quando o TileSet não tem colisão.
const POLIGONO_TILE := [Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)]

# Cenas pré-carregadas dos objetos que a fase instancia.
const CENA_NINO := preload("res://scenes/entities/enemy_nino.tscn")
const CENA_YOTSUBA := preload("res://scenes/entities/enemy_yotsuba.tscn")
const CENA_PROVA := preload("res://scenes/entities/item_prova.tscn")
const CENA_NOTA := preload("res://scenes/entities/item_nota.tscn")
const CENA_SODA := preload("res://scenes/entities/item_soda.tscn")
const CENA_PORTA := preload("res://scenes/entities/door.tscn")

## Limite de inimigos vivos ao mesmo tempo; o spawn dinâmico para ao atingir esse número.
@export var max_inimigos: int = 6
## Limite de refris de matcha presentes no mapa ao mesmo tempo.
@export var max_sodas: int = 2

# Referências aos nós filhos da cena da fase.
@onready var chao: TileMapLayer = $Cenario/Chao
@onready var paredes: TileMapLayer = $Cenario/Paredes
@onready var portas: Node2D = $Portas
@onready var itens: Node2D = $Itens
@onready var inimigos: Node2D = $Inimigos
@onready var projeteis: Node2D = $Projeteis
@onready var jogador: Jogador = $Jogador
@onready var interface = $Interface
@onready var menu_pausa = $MenuPausa
@onready var timer_itens: Timer = $TimerItens
@onready var timer_inimigos: Timer = $TimerInimigos

## Dicionário da fase atual vindo de LevelData.FASES (nome, tempo, objetivo e mapa).
var dados: Dictionary
## Segundos que faltam para o tempo da fase acabar.
var tempo_restante: float = 0.0
## Segundos jogados nesta fase; também aumenta a dificuldade dos novos inimigos.
var tempo_decorrido: float = 0.0
## Fica true quando a fase acaba (vitória ou derrota) para parar o tempo e os spawns.
var terminou: bool = false
## Células sem parede, usadas para sortear posições de spawn.
var celulas_livres: Array[Vector2i] = []
## Porta de saída da fase (caractere D do mapa).
var porta: PortaSaida
## Índice que a próxima prova criada vai receber (uma por irmã).
var _proxima_prova: int = 0
## Largura e altura do mapa em pixels, usadas como limites da câmera.
var _largura_px: int = 0
var _altura_px: int = 0


## Carrega os dados da fase atual, monta o mapa, configura câmera, sinais e HUD
## e inicia os timers de spawn.
func _ready() -> void:
	var indice := clampi(Game.fase_atual, 0, LevelData.FASES.size() - 1)
	dados = LevelData.FASES[indice]
	tempo_restante = dados["tempo"]
	Game.resetar_provas()
	jogador.container_projeteis = projeteis

	_garantir_colisao_do_tileset()
	_construir_mapa(dados["mapa"])
	_configurar_camera()
	_conectar_sinais()

	interface.definir_fase(dados["nome"])
	interface.atualizar_vidas(jogador.vidas)
	interface.atualizar_pontos(Game.pontos)
	interface.atualizar_tempo(tempo_restante)
	interface.mostrar_mensagem(dados["objetivo"], 4.5)

	timer_itens.start()
	timer_inimigos.start()


## Desconta o tempo a cada quadro, atualiza a HUD e causa derrota se o tempo zerar.
func _process(delta: float) -> void:
	if terminou:
		return
	tempo_restante -= delta
	tempo_decorrido += delta
	interface.atualizar_tempo(tempo_restante)
	if tempo_restante <= 0.0:
		_derrota("O tempo acabou! A prova é amanhã e ninguém estudou...")


# ---------------------------------------------------------------- construção da fase
## Cria a camada de física e os polígonos de colisão das paredes caso o TileSet não os tenha.
func _garantir_colisao_do_tileset() -> void:
	# Segurança: se o TileSet não tiver colisão configurada, cria via código.
	var ts := paredes.tile_set
	if ts.get_physics_layers_count() == 0:
		ts.add_physics_layer()
		ts.set_physics_layer_collision_layer(0, 1)
	var fonte := ts.get_source(0) as TileSetAtlasSource
	for coords in PAREDES.values():
		var td := fonte.get_tile_data(coords, 0)
		if td.get_collision_polygons_count(0) == 0:
			td.add_collision_polygon(0)
			td.set_collision_polygon_points(0, 0, PackedVector2Array(POLIGONO_TILE))


## Converte uma célula do mapa na posição (em pixels) do centro dela.
func _centro(celula: Vector2i) -> Vector2:
	return Vector2(celula.x * TAM + TAM / 2.0, celula.y * TAM + TAM / 2.0)


## Percorre o mapa ASCII linha por linha: pinta o chão (xadrez ou tapete), coloca as paredes
## e cria jogador, inimigos, provas, notas e porta conforme cada caractere.
func _construir_mapa(linhas: Array) -> void:
	_altura_px = linhas.size() * TAM
	_largura_px = String(linhas[0]).length() * TAM
	for y in linhas.size():
		var linha: String = linhas[y]
		for x in linha.length():
			var c := linha[x]
			var celula := Vector2i(x, y)
			var pos := _centro(celula)

			var tile_chao := 0 if (x + y) % 2 == 0 else 1
			if c == ",":
				tile_chao = 5
			chao.set_cell(celula, 0, Vector2i(tile_chao, 0))

			if PAREDES.has(c):
				paredes.set_cell(celula, 0, PAREDES[c])
				continue
			celulas_livres.append(celula)

			if c == "P":
				jogador.global_position = pos
			elif c == "N":
				_criar_inimigo(CENA_NINO, pos)
			elif c == "Y":
				_criar_inimigo(CENA_YOTSUBA, pos)
			elif c == "F":
				_criar_prova(pos)
			elif c == "$":
				_criar_item(CENA_NOTA, pos)
			elif c == "D":
				_criar_porta(pos)


## Limita a câmera do jogador às bordas do mapa.
func _configurar_camera() -> void:
	var cam: Camera2D = jogador.camera
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = _largura_px
	cam.limit_bottom = _altura_px
	cam.reset_smoothing()


## Liga os sinais do jogador, do autoload Game, da porta e dos timers aos seus tratadores.
func _conectar_sinais() -> void:
	jogador.vida_mudou.connect(interface.atualizar_vidas)
	jogador.morreu.connect(_ao_jogador_morrer)
	Game.pontos_mudou.connect(interface.atualizar_pontos)
	Game.prova_coletada.connect(interface.marcar_prova)
	porta.jogador_entrou.connect(_ao_entrar_na_porta)
	timer_itens.timeout.connect(_ao_timer_itens)
	timer_inimigos.timeout.connect(_ao_timer_inimigos)


# ---------------------------------------------------------------- criação de objetos
## Cria uma prova numerada na posição dada e conecta o sinal de coleta.
func _criar_prova(pos: Vector2) -> void:
	var p: Coletavel = CENA_PROVA.instantiate()
	p.indice_prova = _proxima_prova
	_proxima_prova += 1
	itens.add_child(p)
	p.global_position = pos
	p.coletado.connect(_ao_coletar)


## Cria um coletável genérico (nota ou refri) na posição dada e conecta o sinal de coleta.
func _criar_item(cena: PackedScene, pos: Vector2) -> void:
	var item: Coletavel = cena.instantiate()
	itens.add_child(item)
	item.global_position = pos
	item.coletado.connect(_ao_coletar)


## Cria a porta de saída e guarda a referência em [member porta].
func _criar_porta(pos: Vector2) -> void:
	porta = CENA_PORTA.instantiate()
	portas.add_child(porta)
	porta.global_position = pos


## Cria um inimigo com fator de dificuldade que cresce com o tempo jogado e com o número da fase.
func _criar_inimigo(cena: PackedScene, pos: Vector2) -> void:
	var e: Inimigo = cena.instantiate()
	e.fator_dificuldade = 1.0 + tempo_decorrido / 240.0 + Game.fase_atual * 0.15
	inimigos.add_child(e)
	e.global_position = pos


## Sorteia uma célula livre a pelo menos [param dist_min] pixels do jogador (até 40 tentativas);
## se não achar, usa a primeira célula livre.
func _posicao_aleatoria(dist_min: float) -> Vector2:
	for i in 40:
		var c: Vector2i = celulas_livres.pick_random()
		var pos := _centro(c)
		if pos.distance_to(jogador.global_position) >= dist_min:
			return pos
	return _centro(celulas_livres[0])


# ---------------------------------------------------------------- spawns dinâmicos
## Chamado pelo TimerItens: cria um refri de matcha longe do jogador se ainda houver espaço.
func _ao_timer_itens() -> void:
	if terminou:
		return
	var sodas := 0
	for i in itens.get_children():
		if i is Coletavel and i.tipo == Coletavel.Tipo.SODA:
			sodas += 1
	if sodas >= max_sodas:
		return
	_criar_item(CENA_SODA, _posicao_aleatoria(160.0))
	interface.mostrar_mensagem("Um refri de matcha apareceu no mapa!", 2.0)


## Chamado pelo TimerInimigos: cria mais uma irmã (alternando Nino e Yotsuba) longe do jogador.
func _ao_timer_inimigos() -> void:
	if terminou or inimigos.get_child_count() >= max_inimigos:
		return
	var cena := CENA_NINO if inimigos.get_child_count() % 2 == 0 else CENA_YOTSUBA
	_criar_inimigo(cena, _posicao_aleatoria(300.0))
	interface.mostrar_mensagem("Mais uma irmã fugiu do estudo!", 2.0)


# ---------------------------------------------------------------- eventos
## Reage à coleta de itens: mostra mensagens e abre a porta quando todas as provas forem pegas.
func _ao_coletar(tipo: int, indice: int) -> void:
	if tipo == Coletavel.Tipo.PROVA:
		var n := Game.total_provas()
		var nome: String = Game.NOMES_IRMAS[indice]
		interface.mostrar_mensagem("Prova da %s recuperada! (%d/%d)" % [nome, n, Game.TOTAL_PROVAS])
		if n >= Game.TOTAL_PROVAS:
			porta.abrir()
			interface.mostrar_mensagem("Todas as provas! Corra para a porta da sala!", 4.0)
	elif tipo == Coletavel.Tipo.SODA:
		interface.mostrar_mensagem("Refri de matcha! Energia recuperada.", 1.5)


## Vence a fase se a porta estiver aberta; senão avisa quantas provas faltam.
func _ao_entrar_na_porta(aberta: bool) -> void:
	if terminou:
		return
	if aberta:
		_vencer_fase()
	else:
		var faltam := Game.TOTAL_PROVAS - Game.total_provas()
		interface.mostrar_mensagem("A porta está trancada! Faltam %d prova(s)." % faltam, 2.5)


## Chamado quando a energia do jogador acaba; termina a fase em derrota.
func _ao_jogador_morrer() -> void:
	_derrota("Fuutarou ficou sem energia... as irmãs venceram a fuga dos estudos!")


## Para a fase: bloqueia a pausa, congela jogador e inimigos, para os timers
## e soma o tempo jogado ao tempo total.
func _congelar_fase() -> void:
	terminou = true
	menu_pausa.permitido = false
	jogador.congelado = true
	inimigos.process_mode = Node.PROCESS_MODE_DISABLED
	timer_itens.stop()
	timer_inimigos.stop()
	Game.tempo_total += tempo_decorrido


## Dá bônus de 5 pontos por segundo restante e vai para a próxima fase,
## ou termina o jogo com vitória se esta for a última.
func _vencer_fase() -> void:
	_congelar_fase()
	var bonus := int(tempo_restante) * 5
	Game.adicionar_pontos(bonus)
	if Game.fase_atual < LevelData.FASES.size() - 1:
		Game.sfx("vitoria")
		interface.mostrar_mensagem("Fase completa! Bônus de tempo: +%d" % bonus, 2.5)
		await get_tree().create_timer(2.5).timeout
		Game.proxima_fase()
	else:
		Game.terminar(true, "As cinco irmãs foram para a prova com o material em dia. Missão cumprida, tutor!")


## Congela a fase e, após uma pequena espera, mostra a tela final de derrota com o texto dado.
func _derrota(texto: String) -> void:
	if terminou:
		return
	_congelar_fase()
	await get_tree().create_timer(0.8).timeout
	Game.terminar(false, texto)

extends Node
## Autoload "Game": estado global, mapa de entradas, áudio e troca de cenas.
##
## Fica carregado durante todo o jogo e é acessado pelos outros scripts
## pelo nome Game (por exemplo Game.sfx("...") ou Game.adicionar_pontos(...)).

## Emitido sempre que a pontuação muda, com o novo total de pontos.
signal pontos_mudou(pontos: int)
## Emitido quando uma prova é recolhida, com o índice dela (0 a TOTAL_PROVAS - 1).
signal prova_coletada(indice: int)

# Caminhos das cenas usadas por ir_para().
const CENA_MENU := "res://scenes/ui/main_menu.tscn"
const CENA_FASE := "res://scenes/levels/level.tscn"
const CENA_FIM := "res://scenes/ui/end_screen.tscn"
const CENA_CREDITOS := "res://scenes/ui/credits.tscn"
## Arquivo (na pasta de dados do usuário) onde o recorde fica salvo.
const ARQUIVO_SAVE := "user://recorde.cfg"

## Vidas no começo de cada partida.
const VIDAS_INICIAIS := 3
## Limite de vidas; o bônus de proxima_fase() nunca passa disso.
const VIDAS_MAX := 5
## Quantidade de provas que existem em cada fase.
const TOTAL_PROVAS := 5
## Nomes das cinco irmãs, na mesma ordem de CORES_IRMAS.
const NOMES_IRMAS: Array[String] = ["Ichika", "Nino", "Miku", "Yotsuba", "Itsuki"]

## Cor de cada irmã, na mesma ordem de NOMES_IRMAS.
var CORES_IRMAS: Array[Color] = [
	Color("6fb0ff"), Color("ff8fbe"), Color("c08a5e"), Color("5fd07a"), Color("ff6b6b")
]

## Índice da fase atual (0 = primeira fase).
var fase_atual: int = 0
## Pontuação da partida atual.
var pontos: int = 0
## Vidas restantes do jogador.
var vidas: int = VIDAS_INICIAIS
## Quais provas já foram recolhidas na fase (true = recolhida).
var provas: Array[bool] = []
## Maior pontuação já feita, carregada de ARQUIVO_SAVE.
var recorde: int = 0
## true se a última partida foi vencida; preenchido por terminar().
var venceu: bool = false
## Texto que explica como a última partida terminou, preenchido por terminar().
var motivo: String = ""
## Tempo total da partida; zerado em iniciar_jogo().
var tempo_total: float = 0.0

## Player da música de fundo, criado em _iniciar_musica().
var _musica: AudioStreamPlayer
## Sons já carregados, guardados pelo nome para não carregar de novo.
var _cache_sfx: Dictionary = {}


## Prepara o autoload: registra os controles, carrega o recorde e começa a música.
func _ready() -> void:
	# PROCESS_MODE_ALWAYS faz o Game continuar rodando com o jogo pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_registrar_entradas()
	_carregar_recorde()
	_iniciar_musica()


# ---------------------------------------------------------------- entradas
## Cria as ações de entrada usadas pelo jogo e as teclas/botões de cada uma.
func _registrar_entradas() -> void:
	_acao("cima", [KEY_W, KEY_UP])
	_acao("baixo", [KEY_S, KEY_DOWN])
	_acao("esquerda", [KEY_A, KEY_LEFT])
	_acao("direita", [KEY_D, KEY_RIGHT])
	_acao("atirar", [KEY_SPACE, KEY_J], [MOUSE_BUTTON_LEFT])
	_acao("pausar", [KEY_ESCAPE, KEY_P])


## Cria a ação [param nome] (se ainda não existir) e liga a ela as teclas
## físicas de [param teclas] e os botões do mouse de [param botoes].
func _acao(nome: StringName, teclas: Array, botoes: Array = []) -> void:
	if not InputMap.has_action(nome):
		InputMap.add_action(nome)
	for k in teclas:
		var e := InputEventKey.new()
		e.physical_keycode = k
		InputMap.action_add_event(nome, e)
	for b in botoes:
		var m := InputEventMouseButton.new()
		m.button_index = b
		InputMap.action_add_event(nome, m)


# ---------------------------------------------------------------- fluxo do jogo
## Começa uma partida nova a partir da primeira fase, zerando pontos, vidas e tempo.
func iniciar_jogo() -> void:
	fase_atual = 0
	pontos = 0
	vidas = VIDAS_INICIAIS
	tempo_total = 0.0
	ir_para(CENA_FASE)


## Avança para a próxima fase e dá uma vida extra (até VIDAS_MAX).
func proxima_fase() -> void:
	fase_atual += 1
	vidas = mini(vidas + 1, VIDAS_MAX)  # bônus por completar a fase
	ir_para(CENA_FASE)


## Encerra a partida: guarda o resultado, salva o recorde se foi batido,
## toca o som de vitória ou derrota e abre a tela final.
func terminar(ganhou: bool, texto: String) -> void:
	venceu = ganhou
	motivo = texto
	if pontos > recorde:
		recorde = pontos
		_salvar_recorde()
	sfx("vitoria" if ganhou else "derrota")
	ir_para(CENA_FIM)


## Volta para o menu inicial.
func ir_para_menu() -> void:
	ir_para(CENA_MENU)


## Abre a tela de créditos.
func ir_para_creditos() -> void:
	ir_para(CENA_CREDITOS)


## Fecha o jogo.
func sair() -> void:
	get_tree().quit()


## Tira a pausa e troca para a cena em [param caminho].
## A troca é adiada (call_deferred) para acontecer com segurança no fim do frame.
func ir_para(caminho: String) -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", caminho)


# ---------------------------------------------------------------- provas e pontos
## Marca todas as TOTAL_PROVAS provas como ainda não recolhidas.
func resetar_provas() -> void:
	provas.clear()
	for i in TOTAL_PROVAS:
		provas.append(false)


## Marca a prova [param indice] como recolhida e emite prova_coletada.
## Índices fora da lista são ignorados.
func coletar_prova(indice: int) -> void:
	if indice >= 0 and indice < provas.size():
		provas[indice] = true
		prova_coletada.emit(indice)


## Retorna quantas provas já foram recolhidas.
func total_provas() -> int:
	var n := 0
	for p in provas:
		if p:
			n += 1
	return n


## Soma [param valor] à pontuação e emite pontos_mudou.
func adicionar_pontos(valor: int) -> void:
	pontos += valor
	pontos_mudou.emit(pontos)


# ---------------------------------------------------------------- áudio
## Toca o efeito sonoro res://assets/audio/<nome>.wav uma vez.
## Cada som cria um AudioStreamPlayer próprio, que se apaga ao terminar.
func sfx(nome: String, volume_db: float = 0.0) -> void:
	if not _cache_sfx.has(nome):
		_cache_sfx[nome] = load("res://assets/audio/%s.wav" % nome)
	var p := AudioStreamPlayer.new()
	p.stream = _cache_sfx[nome]
	p.volume_db = volume_db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


## Cria o player da música de fundo e a toca em repetição
## (ao terminar, ela começa de novo).
func _iniciar_musica() -> void:
	_musica = AudioStreamPlayer.new()
	_musica.stream = load("res://assets/audio/musica.wav")
	_musica.volume_db = -10.0
	_musica.finished.connect(_musica.play)
	add_child(_musica)
	_musica.play()


# ---------------------------------------------------------------- recorde
## Lê o recorde salvo em ARQUIVO_SAVE, se o arquivo existir.
func _carregar_recorde() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARQUIVO_SAVE) == OK:
		recorde = int(cfg.get_value("jogo", "recorde", 0))


## Grava o recorde atual em ARQUIVO_SAVE.
func _salvar_recorde() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("jogo", "recorde", recorde)
	cfg.save(ARQUIVO_SAVE)

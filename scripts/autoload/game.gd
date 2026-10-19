extends Node
## Autoload "Game": estado global, mapa de entradas, áudio e troca de cenas.

signal pontos_mudou(pontos: int)
signal prova_coletada(indice: int)

const CENA_MENU := "res://scenes/ui/main_menu.tscn"
const CENA_FASE := "res://scenes/levels/level.tscn"
const CENA_FIM := "res://scenes/ui/end_screen.tscn"
const CENA_CREDITOS := "res://scenes/ui/credits.tscn"
const ARQUIVO_SAVE := "user://recorde.cfg"

const VIDAS_INICIAIS := 3
const VIDAS_MAX := 5
const TOTAL_PROVAS := 5
const NOMES_IRMAS: Array[String] = ["Ichika", "Nino", "Miku", "Yotsuba", "Itsuki"]

var CORES_IRMAS: Array[Color] = [
	Color("6fb0ff"), Color("ff8fbe"), Color("c08a5e"), Color("5fd07a"), Color("ff6b6b")
]

var fase_atual: int = 0
var pontos: int = 0
var vidas: int = VIDAS_INICIAIS
var provas: Array[bool] = []
var recorde: int = 0
var venceu: bool = false
var motivo: String = ""
var tempo_total: float = 0.0

var _musica: AudioStreamPlayer
var _cache_sfx: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_registrar_entradas()
	_carregar_recorde()
	_iniciar_musica()


# ---------------------------------------------------------------- entradas
func _registrar_entradas() -> void:
	_acao("cima", [KEY_W, KEY_UP])
	_acao("baixo", [KEY_S, KEY_DOWN])
	_acao("esquerda", [KEY_A, KEY_LEFT])
	_acao("direita", [KEY_D, KEY_RIGHT])
	_acao("atirar", [KEY_SPACE, KEY_J], [MOUSE_BUTTON_LEFT])
	_acao("pausar", [KEY_ESCAPE, KEY_P])


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
func iniciar_jogo() -> void:
	fase_atual = 0
	pontos = 0
	vidas = VIDAS_INICIAIS
	tempo_total = 0.0
	ir_para(CENA_FASE)


func proxima_fase() -> void:
	fase_atual += 1
	vidas = mini(vidas + 1, VIDAS_MAX)  # bônus por completar a fase
	ir_para(CENA_FASE)


func terminar(ganhou: bool, texto: String) -> void:
	venceu = ganhou
	motivo = texto
	if pontos > recorde:
		recorde = pontos
		_salvar_recorde()
	sfx("vitoria" if ganhou else "derrota")
	ir_para(CENA_FIM)


func ir_para_menu() -> void:
	ir_para(CENA_MENU)


func ir_para_creditos() -> void:
	ir_para(CENA_CREDITOS)


func sair() -> void:
	get_tree().quit()


func ir_para(caminho: String) -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", caminho)


# ---------------------------------------------------------------- provas e pontos
func resetar_provas() -> void:
	provas.clear()
	for i in TOTAL_PROVAS:
		provas.append(false)


func coletar_prova(indice: int) -> void:
	if indice >= 0 and indice < provas.size():
		provas[indice] = true
		prova_coletada.emit(indice)


func total_provas() -> int:
	var n := 0
	for p in provas:
		if p:
			n += 1
	return n


func adicionar_pontos(valor: int) -> void:
	pontos += valor
	pontos_mudou.emit(pontos)


# ---------------------------------------------------------------- áudio
func sfx(nome: String, volume_db: float = 0.0) -> void:
	if not _cache_sfx.has(nome):
		_cache_sfx[nome] = load("res://assets/audio/%s.wav" % nome)
	var p := AudioStreamPlayer.new()
	p.stream = _cache_sfx[nome]
	p.volume_db = volume_db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _iniciar_musica() -> void:
	_musica = AudioStreamPlayer.new()
	_musica.stream = load("res://assets/audio/musica.wav")
	_musica.volume_db = -10.0
	_musica.finished.connect(_musica.play)
	add_child(_musica)
	_musica.play()


# ---------------------------------------------------------------- recorde
func _carregar_recorde() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARQUIVO_SAVE) == OK:
		recorde = int(cfg.get_value("jogo", "recorde", 0))


func _salvar_recorde() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("jogo", "recorde", recorde)
	cfg.save(ARQUIVO_SAVE)

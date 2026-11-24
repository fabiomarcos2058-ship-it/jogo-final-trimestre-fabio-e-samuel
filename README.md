# Gotoubun Study Run

Jogo top-down feito em **Godot 4.5+** (GDScript), inspirado em *Gotoubun no Hanayome* (*The Quintessential Quintuplets*).
Trabalho prático de Introdução ao Desenvolvimento de Jogos: IFMG, Campus Ribeirão das Neves (Profa. Camila Laranjeira da Silva).

Dupla: **[NOME 1]** e **[NOME 2]**

## Entrega 1: Proposta do jogo

1. **Título:** Gotoubun Study Run
2. **Narrativa/tema:** Na véspera da prova final, as cinco irmãs Nakano (Ichika, Nino, Miku, Yotsuba e Itsuki) escondem os materiais de estudo pela escola para fugir da revisão. Fuutarou Uesugi, o tutor, precisa recuperar as 5 provas e chegar à sala de estudos antes que o tempo acabe.
3. **Objetivo:** Recolher as 5 provas (uma de cada irmã) e entrar na porta da sala, que só abre com todas em mãos. São 2 fases (Colégio e Biblioteca).
4. **Ações do jogador:** mover com **WASD** ou **setas**; arremessar livro com **clique esquerdo** (na direção do mouse) ou **Espaço/J** (na direção em que anda); pausar com **Esc** ou **P**.
5. **Inimigos:** **Nino** patrulha e persegue Fuutarou quando o enxerga (raycast com paredes bloqueando a visão). **Yotsuba** patrulha rápido e desvia ao bater em paredes. Tocar em uma irmã tira 1 vida (1,5 s de invulnerabilidade). Um livro acertado a deixa "estudando" por 3 s (atordoada, +50 pontos). Novas irmãs aparecem com o tempo.
6. **Itens:** **Provas** (objetivo, +200); **Notas de 5000 ienes** (+100); **Refri de matcha** (+1 vida, aparece aleatoriamente no mapa).
7. **Vitória:** recolher as 5 provas e entrar na porta em cada fase (bônus de tempo restante).
8. **Derrota:** perder as 3 vidas ou o tempo (2:30 por fase) acabar.
9. **Progressão:** 2 fases com mapas diferentes; a velocidade dos inimigos aumenta com o tempo e por fase; pontuação com recorde salvo em disco (`user://recorde.cfg`).
10. **Estética:** pixel art (sprites 32x32 originais, gerados por script), paleta quente na escola, trilha e efeitos sonoros chiptune. Referência: *Zelda* (visão top-down) e o anime/mangá de Negi Haruba.

## Requisitos técnicos (Entrega 2)

| Requisito | Onde está |
|---|---|
| Menu inicial (Iniciar, Créditos, Sair) | `scenes/ui/main_menu.tscn` |
| Câmera seguindo o jogador (com limites de mundo) | `Camera2D` em `scenes/entities/player.tscn`; limites em `scripts/levels/level.gd` |
| `TileMapLayer` para o cenário | `Cenario/Chao` e `Cenario/Paredes` em `scenes/levels/level.tscn`; TileSet em `resources/tileset_escola.tres` |
| Inimigo com lógica de comportamento | `scripts/entities/enemy.gd` (patrulha e perseguição) |
| Itens coletáveis | `scripts/entities/collectible.gd` |
| Instância dinâmica | livros (`projectile.tscn`), refris e irmãs extras gerados por `Timer` em `level.gd` |
| Menu de pausa em `CanvasLayer` (com sair) | `scenes/ui/pause_menu.tscn` |
| Tela final (vitória/derrota, reiniciar/menu) | `scenes/ui/end_screen.tscn` |

## Organização

```
assets/     sprites, tileset e áudio (gerados por tools/gerar_assets.py)
resources/  TileSet
scenes/     entities/  levels/  ui/
scripts/    autoload/ (Game)  entities/  levels/  ui/
tools/      geradores de assets e de mapas
```

Os mapas ficam em `scripts/levels/level_data.gd` (ASCII, editável à mão; a legenda está no topo do arquivo).
As ações de teclado/mouse são registradas por código em `scripts/autoload/game.gd`.

## Como abrir

1. Abra o **Godot 4.5 ou mais novo** > **Importar** > selecione `project.godot`.
2. Aguarde a importação dos assets e aperte **F5**.

## Configurações do projeto (`project.godot`)

| Configuração | Valor | Para que serve |
|---|---|---|
| `application/run/main_scene` | `res://scenes/ui/main_menu.tscn` | cena aberta ao apertar **F5** (menu principal) |
| `application/config/features` | `4.5`, `GL Compatibility` | versão da Godot e renderizador usados |
| `autoload` | `Game` → `res://scripts/autoload/game.gd` | singleton global com o estado da partida |
| `display/window/size/viewport_width` × `viewport_height` | 960 × 540 | resolução base da janela |
| `display/window/stretch/mode` | `canvas_items` | a tela é redimensionada mantendo a cena 2D proporcional |
| `rendering/renderer/rendering_method` (e `.mobile`) | `gl_compatibility` | renderizador de compatibilidade, leve e suportado em mais placas de vídeo |
| `rendering/textures/canvas_textures/default_texture_filter` | `0` (Nearest) | mantém a pixel art nítida, sem suavizar os pixels |
| `layer_names/2d_physics` | `mundo`, `jogador`, `inimigos`, `itens`, `projeteis` | nomes das camadas 1 a 5 (veja *Camadas de colisão*) |

## Controles

As ações são criadas por código em `_registrar_entradas()` (`scripts/autoload/game.gd`), então não é preciso configurar o Mapa de Entrada no editor.

| Ação (`InputMap`) | Teclado | Mouse | O que faz |
|---|---|---|---|
| `cima` | **W** / **↑** | | move para cima |
| `baixo` | **S** / **↓** | | move para baixo |
| `esquerda` | **A** / **←** | | move para a esquerda |
| `direita` | **D** / **→** | | move para a direita |
| `atirar` | **Espaço** / **J** | **clique esquerdo** | arremessa um livro; pelo teclado vai na direção em que o jogador olha, com o mouse vai na direção do cursor |
| `pausar` | **Esc** / **P** | | abre ou fecha o menu de pausa |

## Estrutura das cenas

A cena inicial é `scenes/ui/main_menu.tscn` (`run/main_scene` em `project.godot`). O autoload `Game` (`scripts/autoload/game.gd`) fica ativo o tempo todo e troca de tela com `ir_para()`, que tira a pausa e chama `change_scene_to_file` adiado:

| Constante em `game.gd` | Cena |
|---|---|
| `CENA_MENU` | `scenes/ui/main_menu.tscn` |
| `CENA_FASE` | `scenes/levels/level.tscn` |
| `CENA_FIM` | `scenes/ui/end_screen.tscn` |
| `CENA_CREDITOS` | `scenes/ui/credits.tscn` |

### Fase (`scenes/levels/level.tscn`, script `level.gd`)

```
Fase (Node2D)
├── Cenario (Node2D)
│   ├── Chao (TileMapLayer)
│   └── Paredes (TileMapLayer)
├── Portas (Node2D)        ← recebe a porta (door.tscn)
├── Itens (Node2D)         ← recebe provas, notas e refris
├── Inimigos (Node2D)      ← recebe Nino e Yotsuba
├── Projeteis (Node2D)     ← recebe os livros arremessados pelo jogador
├── Jogador                (instância de player.tscn)
├── Interface              (instância de hud.tscn)
├── MenuPausa              (instância de pause_menu.tscn)
├── TimerItens (Timer)
└── TimerInimigos (Timer)
```

Os nós `Portas`, `Itens`, `Inimigos` e `Projeteis` começam vazios: `level.gd` instancia as cenas carregadas com `preload` (`CENA_NINO`, `CENA_YOTSUBA`, `CENA_PROVA`, `CENA_NOTA`, `CENA_SODA`, `CENA_PORTA`) e as adiciona com `add_child`. O livro é criado em `atirar()` de `player.gd`, dentro de `container_projeteis` (ou do pai do jogador, se ele não estiver definido).

### Entidades (`scenes/entities/`)

| Cena | Raiz | Filhos | Script |
|---|---|---|---|
| `player.tscn` | `Jogador` (`CharacterBody2D`) | `Sprite`, `Colisao`, `Camera` (`Camera2D`) | `player.gd` |
| `enemy_nino.tscn` / `enemy_yotsuba.tscn` | `Nino` / `Yotsuba` (`CharacterBody2D`) | `Sprite`, `Colisao`, `AreaDano` (`Area2D` > `Forma`), `Aviso` (`Label`) | `enemy.gd` (o mesmo nas duas) |
| `item_prova.tscn` | `Prova` (`Area2D`) | `Sprite`, `Colisao`, `Nome` (`Label`) | `collectible.gd` |
| `item_nota.tscn` / `item_soda.tscn` | `Nota` / `Soda` (`Area2D`) | `Sprite`, `Colisao` | `collectible.gd` |
| `door.tscn` | `Porta` (`Area2D`) | `Sprite`, `Colisao` | `door.gd` |
| `projectile.tscn` | `Livro` (`Area2D`) | `Sprite`, `Colisao` | `projectile.gd` |

### Interface (`scenes/ui/`)

| Cena | Raiz | Conteúdo principal | Script |
|---|---|---|---|
| `main_menu.tscn` | `MenuPrincipal` (`Control`) | título, subtítulo, 6 `TextureRect` dos personagens, botões Iniciar/Créditos/Sair e `Recorde` | `main_menu.gd` |
| `hud.tscn` | `Interface` (`CanvasLayer`) | `Barra` com `Fase`, `Vidas`, `Pontos`, `Tempo`; `ListaProvas`; `Mensagem` | `hud.gd` |
| `pause_menu.tscn` | `MenuPausa` (`CanvasLayer`) | botões Continuar, Menu e Sair | `pause_menu.gd` |
| `end_screen.tscn` | `TelaFinal` (`Control`) | `Titulo`, `Personagens`, `Motivo`, `Estatisticas`, botões Jogar novamente e Menu | `end_screen.gd` |
| `credits.tscn` | `Creditos` (`Control`) | `Titulo`, `Texto`, `BotaoVoltar` | `credits.gd` |

Os menus usam a mesma montagem: `Fundo` (`ColorRect`) > `Centro` (`CenterContainer`) > `Caixa` (`VBoxContainer`).

## Camadas de colisão

Os nomes das camadas estão em `project.godot` (`[layer_names]`). Na Godot, `collision_layer` diz **em qual camada** o objeto está e `collision_mask` diz **quais camadas** ele detecta (o valor é a soma dos bits: camada 1 = 1, 2 = 2, 3 = 4, 4 = 8, 5 = 16).

| Camada | Nome | Quem está nela |
|---|---|---|
| 1 | `mundo` | paredes do `TileMapLayer` (`resources/tileset_escola.tres`; `_garantir_colisao_do_tileset()` em `level.gd` cria a camada se faltar) |
| 2 | `jogador` | Fuutarou (`player.tscn`) |
| 3 | `inimigos` | corpo da Nino e da Yotsuba (`enemy_nino.tscn`, `enemy_yotsuba.tscn`) |
| 4 | `itens` | prova, nota e refri (`item_prova.tscn`, `item_nota.tscn`, `item_soda.tscn`) |
| 5 | `projeteis` | livro arremessado (`projectile.tscn`) |

| Cena / nó | `collision_layer` | `collision_mask` | Detecta |
|---|---|---|---|
| `Jogador` (`CharacterBody2D`) | 2 | 1 | paredes |
| Irmã (`CharacterBody2D`) | 4 | 1 | paredes |
| Irmã > `AreaDano` (`Area2D`) | 0 | 2 | jogador (é o que tira vida) |
| Itens (`Area2D`) | 8 | 2 | jogador |
| `Porta` (`Area2D`) | 0 | 2 | jogador |
| `Livro` (`Area2D`) | 16 | 5 | paredes e irmãs (1 + 4) |

A visão da Nino usa um raycast só na camada 1 (`enemy.gd`), por isso apenas as paredes bloqueiam a linha de visão.

## Como os assets e os mapas são gerados (`tools/`)

Os sprites, o tileset, os sons e os mapas não foram desenhados à mão: eles saem de dois scripts Python na pasta `tools/`. Rode-os a partir da raiz do projeto.

### `tools/gerar_assets.py` (precisa de **Pillow** e **numpy**)

```
python3 tools/gerar_assets.py
```

| O que gera | Onde salva | Como |
|---|---|---|
| Personagens: `fuutarou`, `ichika`, `nino`, `miku`, `yotsuba`, `itsuki` | `assets/sprites/*.png` | desenhados pixel a pixel numa grade 16x16 (classe `Grade`), com contorno, e ampliados 2x para 32x32 |
| Itens e porta: `prova`, `nota`, `soda`, `livro`, `porta_fechada`, `porta_aberta` | `assets/sprites/*.png` | mesma grade 16x16 ampliada para 32x32 |
| Tileset (atlas com os tiles de 32x32 lado a lado) | `assets/tiles/tileset.png` | montado com numpy em `gerar_tileset()` (semente fixa `7`, então o resultado se repete) |
| Efeitos sonoros e música | `assets/audio/*.wav` | ondas quadrada, triangular e ruído em `onda()`, gravadas como WAV mono 16 bits a 22050 Hz |

As pastas `assets/sprites`, `assets/tiles` e `assets/audio` são criadas se não existirem, e os arquivos antigos são sobrescritos.

### `tools/gerar_mapas.py` (só biblioteca padrão)

```
python3 tools/gerar_mapas.py
```

- Monta os mapas das 2 fases (48 colunas x 30 linhas, com borda de parede) nas funções `fase1()` e `fase2()`.
- Valida cada mapa antes de salvar: uma busca em largura (BFS) a partir do `P` confere se todas as provas (`F`), notas (`$`), inimigos (`N`/`Y`) e a porta (`D`) são alcançáveis sem atravessar `#`, `B` ou `T`, e se há exatamente 5 provas e 1 porta.
- Imprime os mapas no terminal e reescreve **por inteiro** `scripts/levels/level_data.gd` (nome, tempo de 150 s e objetivo de cada fase + o mapa ASCII). Comentários adicionados à mão nesse arquivo se perdem ao rodar o script de novo.

Depois de rodar qualquer um dos dois, abra o projeto na Godot para ela reimportar os arquivos alterados.

## Pontuação, vidas e fim de partida

Todos os pontos passam por `Game.adicionar_pontos()` (`scripts/autoload/game.gd`), que atualiza a HUD pelo sinal `pontos_mudou`.

| Evento | Pontos | Onde está no código |
|---|---|---|
| Recolher uma prova | +200 | `_ao_entrar()` em `scripts/entities/collectible.gd` |
| Recolher uma nota de 5000 ienes | +100 | `_ao_entrar()` em `scripts/entities/collectible.gd` |
| Pegar um refri de matcha com as vidas já no máximo | +50 (no lugar da cura) | `_ao_entrar()` em `scripts/entities/collectible.gd` |
| Acertar um livro em uma irmã que não estava atordoada | +50 | `atordoar()` em `scripts/entities/enemy.gd` |
| Completar a fase | +5 por segundo restante | `_vencer_fase()` em `scripts/levels/level.gd` |

Vidas:

- A partida começa com `VIDAS_INICIAIS = 3` e nunca passa de `VIDAS_MAX = 5`.
- Encostar em uma irmã tira 1 vida (`tomar_dano()` em `scripts/entities/player.gd`) e deixa o jogador invulnerável por `tempo_invulneravel` (1,5 s).
- O refri de matcha cura 1 vida (`curar()`), e passar de fase dá +1 vida (`Game.proxima_fase()`), sempre respeitando o máximo.
- As vidas ficam guardadas em `Game.vidas`, então passam de uma fase para a outra.

Fim de partida:

- **Derrota:** as vidas chegam a 0 ou o tempo da fase (150 s, definido em `level_data.gd`) zera; `_derrota()` em `level.gd` espera 0,8 s e chama `Game.terminar(false, ...)`.
- **Vitória:** ao completar a última fase, `_vencer_fase()` chama `Game.terminar(true, ...)`; nas fases anteriores ela mostra o bônus de tempo por 2,5 s e chama `Game.proxima_fase()`.
- Em `Game.terminar()`, se a pontuação for maior que o recorde, ele é salvo em `user://recorde.cfg` (seção `jogo`, chave `recorde`) e carregado de novo quando o jogo abre.

## GitHub (exigência do trabalho)

Os commits precisam ser semanais, dos dois integrantes e com mensagens descritivas. Sugestão de histórico:

- `adiciona proposta do jogo no README`
- `cria menu inicial com iniciar, créditos e sair`
- `implementa movimento e câmera do jogador`
- `adiciona tilemap do colégio e colisão com paredes`
- `implementa inimigos Nino (persegue) e Yotsuba (patrulha)`
- `adiciona provas, notas e refri coletáveis`
- `cria menu de pausa e tela final`
- `adiciona segunda fase e dificuldade progressiva`

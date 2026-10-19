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

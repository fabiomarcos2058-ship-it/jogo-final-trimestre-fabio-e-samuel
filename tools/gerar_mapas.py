"""Gera scripts/levels/level_data.gd com os mapas ASCII das fases e valida
(BFS) que tudo é alcançável.  Uso: python3 tools/gerar_mapas.py"""
import os
from collections import deque

L, A = 48, 30
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BLOQUEIA = set("#BT")


class Mapa:
    def __init__(self):
        self.g = [["."] * L for _ in range(A)]
        for x in range(L):
            self.g[0][x] = self.g[A - 1][x] = "#"
        for y in range(A):
            self.g[y][0] = self.g[y][L - 1] = "#"

    def s(self, x, y, c):
        self.g[y][x] = c

    def h(self, y, x1, x2, c="#"):
        for x in range(x1, x2 + 1):
            self.g[y][x] = c

    def v(self, x, y1, y2, c="#"):
        for y in range(y1, y2 + 1):
            self.g[y][x] = c

    def box(self, x1, y1, x2, y2, c):
        for y in range(y1, y2 + 1):
            for x in range(x1, x2 + 1):
                self.g[y][x] = c

    def linhas(self):
        return ["".join(r) for r in self.g]

    def validar(self):
        px = py = None
        alvos = []
        for y in range(A):
            for x in range(L):
                c = self.g[y][x]
                if c == "P":
                    px, py = x, y
                if c in "FNYD$":
                    alvos.append((x, y, c))
        vis = {(px, py)}
        q = deque([(px, py)])
        while q:
            x, y = q.popleft()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < L and 0 <= ny < A and (nx, ny) not in vis and self.g[ny][nx] not in BLOQUEIA:
                    vis.add((nx, ny))
                    q.append((nx, ny))
        ruins = [a for a in alvos if (a[0], a[1]) not in vis]
        assert not ruins, f"inalcançáveis: {ruins}"
        assert sum(1 for a in alvos if a[2] == "F") == 5
        assert sum(1 for a in alvos if a[2] == "D") == 1


def fase1():
    m = Mapa()
    for x in (16, 32):
        m.v(x, 1, 28)
    for (y1, y2) in ((6, 8), (20, 22)):
        m.v(16, y1, y2, ".")
    for (y1, y2) in ((5, 7), (21, 23)):
        m.v(32, y1, y2, ".")
    m.h(14, 1, 15)
    m.h(14, 33, 46)
    m.h(14, 7, 9, ".")
    m.h(14, 39, 41, ".")
    # salão central: tapete e pilares/mesas
    m.box(19, 6, 29, 22, ",")
    for (x, y) in ((19, 10), (29, 10), (19, 18), (29, 18), (24, 14)):
        m.s(x, y, "T")
    m.h(14, 22, 26, ",")
    m.s(24, 14, "T")
    # estantes nas paredes dos cômodos
    for x in (2, 3, 4, 10, 11, 12):
        m.s(x, 1, "B")
        m.s(x, 28, "B")
    for x in (35, 36, 37, 43, 44, 45):
        m.s(x, 1, "B")
        m.s(x, 28, "B")
    # carteiras nos cômodos
    for (x1, y1) in ((4, 5), (10, 10), (4, 18), (11, 24), (36, 4), (42, 9), (36, 17), (42, 22)):
        m.box(x1, y1, x1 + 1, y1, "T")
    m.box(7, 3, 8, 3, "T")
    m.box(38, 25, 39, 25, "T")
    # porta de saída, jogador, itens
    m.s(24, 1, "D")
    m.s(24, 27, "P")
    for (x, y) in ((3, 11), (44, 3), (3, 26), (44, 25), (24, 4)):
        m.s(x, y, "F")
    for (x, y) in ((13, 3), (8, 12), (14, 18), (2, 22), (8, 26), (24, 9), (21, 20),
                   (27, 17), (36, 9), (45, 12), (35, 20), (41, 27), (22, 24), (26, 24)):
        m.s(x, y, "$")
    m.s(24, 11, "N")
    m.s(8, 7, "Y")
    m.s(40, 20, "Y")
    m.validar()
    return m


def fase2():
    m = Mapa()
    # biblioteca: fileiras de estantes com corredores
    for x in (8, 14, 20, 26, 32, 38):
        m.v(x, 2, 11, "B")
        m.v(x, 18, 27, "B")
    # aberturas nas fileiras (passagens entre corredores)
    for x in (8, 20, 32):
        m.v(x, 6, 7, ".")
        m.v(x, 22, 23, ".")
    for x in (14, 26, 38):
        m.v(x, 4, 5, ".")
        m.v(x, 24, 25, ".")
    # corredor central com mesas de estudo
    m.box(4, 14, 43, 15, ",")
    for x in (10, 18, 30, 40):
        m.box(x, 13, x + 1, 13, "T")
        m.box(x, 16, x + 1, 16, "T")
    # paredes internas extras
    m.h(12, 1, 5)
    m.h(17, 42, 46)
    m.h(12, 44, 46)
    m.h(17, 1, 4)
    m.s(24, 1, "D")
    m.s(4, 27, "P")
    for (x, y) in ((3, 3), (17, 4), (35, 8), (44, 27), (23, 24)):
        m.s(x, y, "F")
    for (x, y) in ((11, 3), (5, 9), (17, 9), (23, 10), (29, 4), (41, 4), (45, 10),
                   (5, 20), (11, 25), (17, 20), (29, 26), (35, 22), (41, 24), (45, 20),
                   (12, 14), (24, 15), (36, 14)):
        m.s(x, y, "$")
    m.s(24, 8, "N")
    m.s(36, 22, "N")
    m.s(12, 21, "Y")
    m.s(30, 5, "Y")
    m.validar()
    return m


def escrever(fases):
    linhas = ["# GERADO por tools/gerar_mapas.py — pode editar à mão também.",
              "# Legenda: # parede | B estante | T mesa | . chão | , tapete",
              "#   P jogador | N Nino (persegue) | Y Yotsuba (patrulha)",
              "#   F prova | $ nota de 5000 ienes | D porta de saída",
              "class_name LevelData", "", "const FASES: Array = ["]
    for i, (nome, tempo, obj, mapa) in enumerate(fases):
        linhas.append("\t{")
        linhas.append(f'\t\t"nome": "{nome}",')
        linhas.append(f'\t\t"tempo": {tempo}.0,')
        linhas.append(f'\t\t"objetivo": "{obj}",')
        linhas.append('\t\t"mapa": [')
        for r in mapa.linhas():
            linhas.append(f'\t\t\t"{r}",')
        linhas.append("\t\t],")
        linhas.append("\t}" + ("," if i < len(fases) - 1 else ""))
    linhas.append("]")
    caminho = os.path.join(RAIZ, "scripts/levels/level_data.gd")
    with open(caminho, "w", encoding="utf-8") as f:
        f.write("\n".join(linhas) + "\n")


if __name__ == "__main__":
    f1, f2 = fase1(), fase2()
    for m in (f1, f2):
        print("\n".join(m.linhas()))
        print()
    escrever([
        ("Fase 1 - Colégio Kōryō", 150, "Recolha as 5 provas e vá até a porta da sala!", f1),
        ("Fase 2 - Biblioteca da Escola", 150, "Mais irmãs distraídas! Recolha as 5 provas de novo!", f2),
    ])
    print("level_data.gd gerado")

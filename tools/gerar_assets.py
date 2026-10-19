"""Gera os sprites, tileset e áudios (procedurais, originais) do jogo.
Uso: python3 tools/gerar_assets.py   (requer Pillow e numpy)"""
import os, wave
import numpy as np
from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPR = os.path.join(RAIZ, "assets/sprites")
TIL = os.path.join(RAIZ, "assets/tiles")
AUD = os.path.join(RAIZ, "assets/audio")
CONTORNO = (35, 24, 48, 255)


def hexc(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


class Grade:
    """Tela de pixels 16x16 que depois é ampliada 2x (32x32)."""

    def __init__(self, n=16):
        self.n = n
        self.p = {}

    def px(self, x, y, c):
        if 0 <= x < self.n and 0 <= y < self.n:
            self.p[(x, y)] = c

    def rect(self, x1, y1, x2, y2, c):
        for y in range(y1, y2 + 1):
            for x in range(x1, x2 + 1):
                self.px(x, y, c)

    def contorno(self, c=CONTORNO):
        novos = {}
        for (x, y) in self.p:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (x + dx, y + dy)
                if q not in self.p and 0 <= q[0] < self.n and 0 <= q[1] < self.n:
                    novos[q] = c
        self.p.update(novos)

    def salvar(self, caminho, escala=2):
        img = Image.new("RGBA", (self.n, self.n), (0, 0, 0, 0))
        for (x, y), c in self.p.items():
            img.putpixel((x, y), c)
        img = img.resize((self.n * escala, self.n * escala), Image.NEAREST)
        img.save(caminho)


PELE = hexc("f6d3b3")
BRANCO = hexc("ffffff")
OLHO = hexc("2a2030")
UNIF = hexc("35446e")
SAIA = hexc("6b6f8a")
SAPATO = hexc("2a2030")


def personagem(nome, cabelo, acess, saia=SAIA, unif=UNIF):
    g = Grade()
    g.rect(4, 1, 11, 7, cabelo)
    g.rect(4, 8, 5, 10, cabelo)
    g.rect(10, 8, 11, 10, cabelo)
    g.rect(5, 3, 10, 7, PELE)
    g.rect(5, 2, 10, 3, cabelo)
    g.px(5, 4, cabelo)
    g.px(10, 4, cabelo)
    g.px(6, 5, OLHO)
    g.px(9, 5, OLHO)
    g.px(6, 6, hexc("f0a8a0"))
    g.px(9, 6, hexc("f0a8a0"))
    g.rect(6, 8, 9, 12, unif)
    g.rect(5, 9, 5, 11, unif)
    g.rect(10, 9, 10, 11, unif)
    g.px(7, 8, BRANCO)
    g.px(8, 8, BRANCO)
    g.px(7, 9, hexc("d94a4a"))
    g.px(8, 9, hexc("d94a4a"))
    g.rect(5, 12, 10, 13, saia)
    g.px(6, 14, PELE)
    g.px(9, 14, PELE)
    g.rect(6, 15, 7, 15, SAPATO)
    g.rect(8, 15, 9, 15, SAPATO)
    acess(g)
    g.contorno()
    g.salvar(os.path.join(SPR, nome + ".png"))


def ac_ichika(g):
    g.px(10, 2, hexc("4aa3ff"))
    g.px(10, 3, hexc("4aa3ff"))
    g.px(9, 2, hexc("ffffff"))


def ac_nino(g):
    for x in (3, 12):
        g.rect(x, 2, x, 3, hexc("e0457b"))
    g.px(3, 4, hexc("c93a6c"))
    g.px(12, 4, hexc("c93a6c"))


def ac_miku(g):
    fone = hexc("2d2d3a")
    g.rect(3, 3, 3, 6, fone)
    g.rect(12, 3, 12, 6, fone)
    g.rect(4, 0, 11, 0, fone)
    g.px(3, 4, hexc("4dd0c8"))
    g.px(12, 4, hexc("4dd0c8"))


def ac_yotsuba(g):
    g.rect(5, 0, 10, 1, hexc("3fbf5a"))
    g.px(7, 0, hexc("2a9445"))
    g.px(8, 0, hexc("2a9445"))


def ac_itsuki(g):
    r = hexc("ff4d5a")
    for (x, y) in ((4, 2), (4, 3), (3, 2), (11, 2), (11, 3), (12, 2)):
        g.px(x, y, r)


def ac_fuu(g):
    cab = hexc("2b2b3a")
    for (x, y) in ((5, 0), (7, 0), (9, 0), (10, 1)):
        g.px(x, y, cab)
    g.rect(2, 10, 4, 12, hexc("3b7dd8"))
    g.rect(2, 10, 2, 12, hexc("2a5cae"))
    g.rect(3, 11, 4, 11, BRANCO)


def gerar_personagens():
    personagem("ichika", hexc("6f9ad8"), ac_ichika)
    personagem("nino", hexc("e88bb4"), ac_nino)
    personagem("miku", hexc("9a6a4a"), ac_miku)
    personagem("yotsuba", hexc("e8a84a"), ac_yotsuba)
    personagem("itsuki", hexc("d98a6a"), ac_itsuki)
    personagem("fuutarou", hexc("2b2b3a"), ac_fuu, saia=hexc("2f3652"), unif=hexc("2d3a63"))


def gerar_itens():
    g = Grade()  # prova (folha)
    g.rect(4, 2, 11, 13, hexc("f4f4f0"))
    g.rect(4, 2, 11, 3, hexc("cfd8ff"))
    for y in (5, 7, 9, 11):
        g.rect(5, y, 10, y, hexc("8a8fa8"))
    g.rect(9, 12, 10, 12, hexc("e0454a"))
    g.contorno()
    g.salvar(os.path.join(SPR, "prova.png"))

    g = Grade()  # nota de 5000 ienes
    g.rect(2, 4, 13, 11, hexc("a58ad6"))
    g.rect(3, 5, 12, 10, hexc("cbb8ee"))
    g.rect(6, 6, 9, 9, hexc("a58ad6"))
    g.rect(7, 7, 8, 8, hexc("ffe9a0"))
    g.contorno()
    g.salvar(os.path.join(SPR, "nota.png"))

    g = Grade()  # refrigerante de matcha
    g.rect(5, 2, 10, 13, hexc("58c46a"))
    g.rect(5, 2, 10, 3, hexc("c8d0d8"))
    g.rect(5, 12, 10, 13, hexc("c8d0d8"))
    g.rect(6, 6, 9, 9, hexc("f4fff2"))
    g.rect(7, 7, 8, 8, hexc("58c46a"))
    g.contorno()
    g.salvar(os.path.join(SPR, "soda.png"))

    g = Grade()  # livro (projétil)
    g.rect(4, 4, 11, 11, hexc("3b7dd8"))
    g.rect(4, 4, 5, 11, hexc("2a5cae"))
    g.rect(6, 5, 11, 6, hexc("ffffff"))
    g.rect(6, 9, 11, 10, hexc("ffffff"))
    g.contorno()
    g.salvar(os.path.join(SPR, "livro.png"))

    for nome, aberta in (("porta_fechada", False), ("porta_aberta", True)):
        g = Grade()
        g.rect(3, 1, 12, 15, hexc("7a4a2a"))
        g.rect(4, 2, 11, 15, hexc("2a1c14") if aberta else hexc("a8683a"))
        if aberta:
            g.rect(5, 3, 10, 15, hexc("fff2b0"))
        else:
            g.rect(5, 4, 10, 8, hexc("b87a48"))
            g.rect(5, 10, 10, 14, hexc("b87a48"))
            g.px(10, 9, hexc("ffd84a"))
        g.rect(4, 0, 11, 0, hexc("3fbf5a") if aberta else hexc("e0454a"))
        g.contorno()
        g.salvar(os.path.join(SPR, nome + ".png"))


def gerar_tileset():
    rng = np.random.default_rng(7)
    tiles = []

    def novo(base):
        t = np.zeros((32, 32, 4), dtype=np.uint8)
        t[:, :] = base
        return t

    t = novo(hexc("e9d8a8"))  # 0 chão A
    for y in range(0, 32, 8):
        t[y, :] = hexc("d9c58f")
    for _ in range(30):
        t[rng.integers(0, 32), rng.integers(0, 32)] = hexc("dcc994")
    tiles.append(t)

    t = novo(hexc("e0cd9a"))  # 1 chão B
    for y in range(0, 32, 8):
        t[y, :] = hexc("cfba82")
    for _ in range(30):
        t[rng.integers(0, 32), rng.integers(0, 32)] = hexc("d4c08a")
    tiles.append(t)

    t = novo(hexc("3d4a6e"))  # 2 parede
    for y in range(0, 32, 8):
        t[y, :] = hexc("2c3652")
    for y in range(0, 32, 16):
        for x in range(0, 32, 16):
            t[y:y + 8, x] = hexc("2c3652")
    for y in range(8, 32, 16):
        for x in range(8, 32, 16):
            t[y:y + 8, x] = hexc("2c3652")
    t[0:2, :] = hexc("5a6a94")
    tiles.append(t)

    t = novo(hexc("6b4426"))  # 3 estante
    cores = [hexc(c) for c in ("d94a4a", "3b7dd8", "58c46a", "e8c04a", "a58ad6", "e88bb4")]
    for fila in (3, 17):
        x = 3
        while x < 27:
            w = int(rng.integers(3, 6))
            c = cores[int(rng.integers(0, len(cores)))]
            t[fila:fila + 10, x:x + w] = c
            x += w + 1
        t[fila + 10:fila + 13, 2:30] = hexc("4a2e18")
    t[0:2, :] = hexc("8a5a34")
    t[:, 0:2] = hexc("4a2e18")
    t[:, 30:32] = hexc("4a2e18")
    tiles.append(t)

    t = novo(hexc("e9d8a8"))  # 4 mesa
    t[4:24, 2:30] = hexc("b8834e")
    t[4:8, 2:30] = hexc("d2a26a")
    t[24:30, 4:8] = hexc("7a4a2a")
    t[24:30, 24:28] = hexc("7a4a2a")
    t[9:13, 8:20] = hexc("f4f4f0")
    t[11, 9:19] = hexc("8a8fa8")
    tiles.append(t)

    t = novo(hexc("c9607a"))  # 5 tapete
    t[2:30, 2:30] = hexc("d97a92")
    t[6:26, 6:26] = hexc("c9607a")
    t[10:22, 10:22] = hexc("e8a0b0")
    tiles.append(t)

    atlas = np.concatenate(tiles, axis=1)
    Image.fromarray(atlas, "RGBA").save(os.path.join(TIL, "tileset.png"))


# ---------------- áudio ----------------
SR = 22050


def onda(freq, dur, tipo="quad", vol=0.4):
    n = int(SR * dur)
    t = np.arange(n) / SR
    if tipo == "quad":
        s = np.sign(np.sin(2 * np.pi * freq * t))
    elif tipo == "tri":
        s = 2 * np.abs(2 * ((freq * t) % 1) - 1) - 1
    elif tipo == "ruido":
        s = np.random.default_rng(1).uniform(-1, 1, n)
    else:
        s = np.sin(2 * np.pi * freq * t)
    s = s * np.minimum(1, np.linspace(1, 0, n) * 4) * np.minimum(1, np.arange(n) / 80)
    return s * vol


def salvar_wav(nome, dados):
    dados = np.clip(dados, -1, 1)
    pcm = (dados * 32767).astype(np.int16)
    with wave.open(os.path.join(AUD, nome + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def nota(n):
    return 440.0 * 2 ** (n / 12)


def gerar_audio():
    salvar_wav("coleta", np.concatenate([onda(nota(x), 0.07) for x in (3, 7, 12)]))
    salvar_wav("prova", np.concatenate([onda(nota(x), 0.09) for x in (0, 4, 7, 12, 16)]))
    salvar_wav("dano", np.concatenate([onda(nota(-5), 0.12), onda(nota(-12), 0.2)]))
    salvar_wav("tiro", np.concatenate([onda(nota(8), 0.04), onda(nota(14), 0.05)]))
    salvar_wav("acerto", np.concatenate([onda(nota(-2), 0.06, "ruido", 0.3), onda(nota(5), 0.1)]))
    salvar_wav("vitoria", np.concatenate([onda(nota(x), 0.14) for x in (0, 4, 7, 12, 7, 12, 16)]))
    salvar_wav("derrota", np.concatenate([onda(nota(x), 0.2, "tri", 0.5) for x in (3, 0, -4, -9)]))
    salvar_wav("porta", np.concatenate([onda(nota(x), 0.06, "tri") for x in (-9, -5, 0, 7)]))
    C, D, E, F, G, A, B = -9, -7, -5, -4, -2, 0, 2
    mel = [E + 12, G + 12, E + 12, D + 12, C + 12, D + 12, E + 12, G, A, C + 12, A, G,
           E + 12, G + 12, E + 12, D + 12, C + 12, E + 12, D + 12, C + 12, B, D + 12, C + 12, None]
    baixo = [C - 12, G - 12, C - 12, G - 12, F - 12, C - 12, F - 12, C - 12, G - 12, D - 12, G - 12, D - 12]
    dur = 0.24
    faixa = np.concatenate([onda(nota(m), dur, "quad", 0.13) if m is not None
                            else np.zeros(int(SR * dur)) for m in mel])
    b = np.concatenate([onda(nota(x), dur * 2, "tri", 0.25) for x in baixo])
    if len(b) < len(faixa):
        b = np.pad(b, (0, len(faixa) - len(b)))
    salvar_wav("musica", faixa + b[:len(faixa)])


if __name__ == "__main__":
    for d in (SPR, TIL, AUD):
        os.makedirs(d, exist_ok=True)
    gerar_personagens()
    gerar_itens()
    gerar_tileset()
    gerar_audio()
    print("assets gerados")

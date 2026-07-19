#!/usr/bin/env python3
# Genera el wallpaper SVG temático para cada tema, rotando los colores
# de la mini-paleta del wallpaper con el motor horus_themes (misma rotación
# que la UI). Uso: python3 horus_wallpaper.py base.svg salida_dir/
import sys, os, re
import horus_themes as kt

def generar(svg_base, outdir):
    os.makedirs(outdir, exist_ok=True)
    with open(svg_base, encoding="utf-8") as f:
        plantilla = f.read()
    for tema in kt.lista_temas():
        pal = kt.construir(tema)
        out = plantilla
        for hex_orig, rol in kt.WALLPAPER.items():
            out = re.sub(re.escape(hex_orig), pal[rol], out, flags=re.IGNORECASE)
        slug = tema.lower().replace(" ", "_")
        ruta = os.path.join(outdir, f"horus_{slug}.svg")
        with open(ruta, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"  {tema:16s} -> {ruta}")

if __name__ == "__main__":
    generar(sys.argv[1], sys.argv[2])

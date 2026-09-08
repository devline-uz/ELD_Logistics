#!/usr/bin/env python3
"""Figma ekran JSON'ini ixcham matn konturiga aylantiradi.

Xom JSON 32–96 KB (bir qatorda) — uni to'liq o'qish agent kontekstini yeydi.
Bu skript o'sha ma'lumotni ~3–6 KB konturga siqadi: har tugun bitta qator.

Ishlatish:
  python3 tool/figma_spec.py <nodeId|nom bo'lagi>            # to'liq kontur
  python3 tool/figma_spec.py <...> --depth 4                 # chuqurlikni cheklash
  python3 tool/figma_spec.py <...> --text                    # faqat matn tugunlari
  python3 tool/figma_spec.py <...> --find "Login"            # nom bo'yicha shox
  python3 tool/figma_spec.py --list                          # mavjud ekranlar
"""
import json, sys, glob, os, argparse

BASE = os.path.join(os.path.dirname(__file__), '..', 'design', 'figma', 'screens')

def find(q):
    key = q.replace(':', '-')
    hits = [p for p in glob.glob(os.path.join(BASE, '*.json'))
            if key.lower() in os.path.basename(p).lower()]
    if not hits:
        sys.exit(f"topilmadi: {q}\n`--list` bilan mavjudlarini ko'ring")
    return sorted(hits, key=len)[0]

def fmt(n, depth):
    p = ['  ' * depth + n.get('n', '?')[:34]]
    p.append(f"[{n.get('t','')[:5]}]")
    w, h = n.get('w'), n.get('h')
    if w is not None:
        p.append(f"{w}x{h}")
    if n.get('x') is not None and depth:
        p.append(f"@{n['x']},{n['y']}")
    if n.get('lay'):
        p.append(f"{n['lay'][:1]}gap{n.get('gap')}pad{n.get('pad')}")
        if n.get('align'):
            p.append('/'.join(str(a)[:6] for a in n['align'] if a))
    if n.get('r'):
        p.append(f"r{n['r']}")
    if n.get('fill'):
        p.append(f"fill{n['fill']}")
    if n.get('stroke'):
        p.append(f"str{n['stroke']}@{n.get('sw')}")
    if n.get('fx'):
        p.append(f"fx{[e['t'][:4] + str(e['r']) for e in n['fx']]}")
    if n.get('op'):
        p.append(f"op{n['op']}")
    if n.get('t') == 'TEXT':
        p.append(f'"{n.get("txt","")[:40]}"')
        p.append(f"{n.get('font')} {n.get('fs')}/{n.get('lh')} ls{n.get('ls')} {n.get('al')}")
    return ' '.join(p)

def walk(n, depth, maxd, out, textonly):
    if not textonly or n.get('t') == 'TEXT':
        out.append(fmt(n, depth))
    if depth < maxd:
        for c in n.get('c', []):
            walk(c, depth + 1, maxd, out, textonly)

a = argparse.ArgumentParser(add_help=False)
a.add_argument('query', nargs='?')
a.add_argument('--depth', type=int, default=99)
a.add_argument('--text', action='store_true')
a.add_argument('--find')
a.add_argument('--list', action='store_true')
o = a.parse_args()

if o.list or not o.query:
    for p in sorted(glob.glob(os.path.join(BASE, '*.json'))):
        print(f"{os.path.getsize(p)//1024:>4}KB  {os.path.basename(p)[:-5]}")
    sys.exit()

path = find(o.query)
root = json.load(open(path))
print(f"# {os.path.basename(path)}  ({os.path.getsize(path)//1024}KB xom)")
if o.find:
    found = []
    def scan(n, d):
        if o.find.lower() in n.get('n', '').lower() or o.find.lower() in n.get('txt', '').lower():
            found.append((n, d))
        for c in n.get('c', []):
            scan(c, d + 1)
    scan(root, 0)
    for n, d in found:
        out = []
        walk(n, 0, o.depth, out, o.text)
        print('\n'.join(out))
        print()
else:
    out = []
    walk(root, 0, o.depth, out, o.text)
    print('\n'.join(out))

#!/usr/bin/env python3
"""Figma ekran JSON'idan implementatsiyaga tayyor spec karta generatsiya qiladi.

`design/figma/screens/*.json` (14-96 KB, bir qatorli xom eksport) →
`design/figma/spec/<M-ID>__<nodeId>.md` (~3-6 KB, markdown).

Karta tarkibi: sarlavha (ID, nodeId light/dark, o'lcham, png_ref, kod fayli) ·
layout daraxti (hidden shoxlarsiz, rang tokenlari bilan) · matn tugunlari jadvali ·
o'lchov xulosasi (radius/gap/pad/stroke chastotasi) · ogohlantirishlar.

Ishlatish:
  python3 tool/figma_speccard.py --all           # hamma ekran
  python3 tool/figma_speccard.py 958:44          # bitta ekran (958-44 ham bo'ladi)
  python3 tool/figma_speccard.py --index         # spec/INDEX.md ni yozish
  python3 tool/figma_speccard.py --all --index   # ikkalasi
"""

import argparse
import glob
import json
import os
import re
import sys
from collections import Counter, OrderedDict

# --------------------------- yo'llar ---------------------------

MOBILE = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
FIGMA = os.path.join(MOBILE, 'design', 'figma')
SCREENS = os.path.join(FIGMA, 'screens')
PNG_REF = os.path.join(FIGMA, 'png_ref')
SPEC = os.path.join(FIGMA, 'spec')
TOKENS = os.path.join(FIGMA, 'tokens.json')
MAP_MD = os.path.join(FIGMA, 'MAP.md')

MAX_BYTES = 8 * 1024          # karta hajmi chegarasi
DEFAULT_DEPTH = 5             # daraxt chuqurligi
NAME_LEN = 34                 # tugun nomi kesimi
TXT_LEN = 60                  # matn qiymati kesimi

# Ikonka primitivlari - bitta satrga siqiladi
PRIMITIVES = {'VECTOR', 'BOOLEAN_OPERATION', 'LINE', 'STAR', 'ELLIPSE', 'RECTANGLE', 'POLYGON'}

FONT_STYLES = ('ExtraLight', 'ExtraBold', 'SemiBold', 'Thin', 'Light', 'Regular',
               'Medium', 'Bold', 'Black', 'Italic', 'Oblique')

# M-ID -> lib/ dagi ekran fayli (registr: .claude/skills/eld-screens/SKILL.md §1).
# Mavjudligi generatsiya paytida tekshiriladi; fayl yo'q bo'lsa INDEX da "—".
CODE_MAP = {
    'M-01': 'auth/presentation/screens/splash_screen.dart',
    'M-02': 'auth/presentation/screens/login_screen.dart',
    'M-04': 'auth/presentation/screens/pin_screen.dart',
    'M-05': 'auth/presentation/screens/invitation_screen.dart',
    'M-08': 'auth/presentation/screens/totp_screen.dart',
    'M-09': 'home/presentation/screens/home_screen.dart',
    'M-10': 'home/presentation/screens/home_screen.dart',
    'M-11': 'home/presentation/screens/home_screen.dart',
    'M-12': 'duty_status/presentation/screens/change_duty_status_screen.dart',
    'M-13': 'duty_status/presentation/screens/change_duty_status_screen.dart',
    'M-14': 'duty_status/presentation/screens/change_duty_status_screen.dart',
    'M-15': 'drive_mode/presentation/screens/drive_mode_screen.dart',
    'M-16': 'drive_mode/presentation/screens/drive_mode_screen.dart',
    'M-18': 'eld_device/presentation/screens/permissions_screen.dart',
    'M-19': 'eld_device/presentation/screens/eld_connect_screen.dart',
    'M-22': 'logs/presentation/screens/log_report_screen.dart',
    'M-23': 'logs/presentation/screens/log_report_screen.dart',
    'M-24': 'logs/presentation/screens/log_report_screen.dart',
    'M-25': 'logs/presentation/screens/log_report_screen.dart',
    'M-26': 'log_edits/presentation/screens/pending_edits_screen.dart',
    'M-27': 'log_edits/presentation/screens/pending_edit_detail_screen.dart',
    'M-28': 'unidentified/presentation/screens/unidentified_screen.dart',
    'M-29': 'certify/presentation/screens/certify_screen.dart',
    'M-30': 'certify/presentation/screens/certify_sign_screen.dart',
    'M-31': 'certify/presentation/screens/certify_screen.dart',
    'M-32': 'dvir/presentation/screens/dvir_add_screen.dart',
    'M-33': 'dvir/presentation/screens/dvir_defect_picker_screen.dart',
    'M-34': 'dvir/presentation/screens/dvir_review_screen.dart',
    'M-35': 'dvir/presentation/screens/dvir_details_screen.dart',
    'M-37': 'inspection/presentation/screens/inspection_report_screen.dart',
    'M-38': 'inspection/presentation/screens/inspection_kiosk_screen.dart',
    'M-40': 'inspection/presentation/screens/inspection_report_screen.dart',
    'M-41': 'inspection/presentation/screens/inspection_report_screen.dart',
    'M-42': 'chat/presentation/screens/chat_screen.dart',
    'M-43': 'notifications/presentation/screens/notifications_screen.dart',
    'M-44': 'profile/presentation/screens/profile_screen.dart',
    'M-45': 'settings/presentation/screens/settings_screen.dart',
    'M-46': 'diagnostics/presentation/screens/diagnosis_screen.dart',
    'M-47': 'diagnostics/presentation/screens/check_network_screen.dart',
    'M-48': 'feedback/presentation/screens/feedback_screen.dart',
    'M-49': 'support/presentation/screens/support_form_screen.dart',
    'M-50': 'support/presentation/screens/support_list_screen.dart',
    'M-51': 'support/presentation/screens/ticket_thread_screen.dart',
    'M-52': 'legal/presentation/screens/legal_screen.dart',
    'M-53': 'legal/presentation/screens/legal_screen.dart',
    'M-54': 'sync/presentation/screens/sync_status_screen.dart',
    'M-55': 'sync/presentation/screens/sync_conflicts_screen.dart',
    'M-56': 'auth/presentation/screens/signed_out_screen.dart',
    'M-57': 'auth/presentation/screens/force_update_screen.dart',
    'M-58': 'auth/presentation/screens/sessions_screen.dart',
}


# --------------------------- yordamchilar ---------------------------

def num(v):
    """Sonni qisqa ko'rinishda beradi: 12.0 -> 12, 15.74 -> 15.74."""
    if v is None:
        return ''
    if isinstance(v, float):
        if abs(v - round(v)) < 1e-6:
            return str(int(round(v)))
        return '%g' % v
    return str(v)


def dash_id(node_id):
    """`958:44` -> `958-44` (fayl nomi ko'rinishi)."""
    return node_id.replace(':', '-')


def colon_id(node_id):
    """`958-44` -> `958:44` (Figma ko'rinishi)."""
    return node_id.replace('-', ':')


def md_cell(s):
    """Markdown jadval katakchasi uchun xavfsiz matn."""
    return str(s).replace('|', '\\|').replace('\n', '/').replace('\r', '')


# --------------------------- tokenlar ---------------------------

def load_tokens():
    """tokens.json ni o'qib, hex -> token nomi lug'atini va tipografikani qaytaradi."""
    with open(TOKENS, encoding='utf-8') as fh:
        tk = json.load(fh)
    hexmap = OrderedDict()

    def put(hx, name):
        """Bitta hex qiymatni token nomiga bog'laydi."""
        if not isinstance(hx, str) or not hx.startswith('#'):
            return
        hexmap.setdefault(hx.upper(), []).append(name)

    for k, v in (tk.get('colors') or {}).items():
        if isinstance(v, dict):
            put(v.get('hex'), k)
    for k, v in (tk.get('neutral') or {}).items():
        put(v, 'neutral.' + k)
    for grp, sub in (tk.get('state') or {}).items():
        if isinstance(sub, dict):
            for k, v in sub.items():
                put(v, 'state.%s.%s' % (grp, k))
    for k, v in (tk.get('decorative') or {}).items():
        put(v, 'decorative.' + k)
    return tk, hexmap


def token_of(hexmap, paint):
    """Rang qiymati uchun token nomini topadi; topilmasa None."""
    if not isinstance(paint, str) or not paint.startswith('#'):
        return None
    base = paint.split('/')[0].upper()
    names = hexmap.get(base)
    return names[0] if names else None


def paint_str(hexmap, paint):
    """Rangni `#FFFFFF (white)` ko'rinishida beradi; token yo'q bo'lsa belgilaydi."""
    if not isinstance(paint, str):
        return str(paint)
    if not paint.startswith('#'):
        return paint  # IMAGE / GRADIENT_LINEAR
    tok = token_of(hexmap, paint)
    return '%s (%s)' % (paint, tok) if tok else "%s (TOKEN YO'Q)" % paint


# --------------------------- MAP.md ---------------------------

NODE_RE = re.compile(r'`(\d+:\d+)`')


def parse_map():
    """MAP.md §1 va §7.2 jadvallaridan nodeId -> ekran ID/nom/dark nodeId xaritasi."""
    by_node = {}
    rows = []
    with open(MAP_MD, encoding='utf-8') as fh:
        for line in fh:
            if not line.startswith('|'):
                continue
            cols = [c.strip() for c in line.strip().strip('|').split('|')]
            if len(cols) < 4:
                continue
            sid = cols[0].replace('**', '').strip()
            if not re.match(r'^[MT]-\d', sid):
                continue
            name = cols[1].replace('**', '').strip()
            light = NODE_RE.findall(cols[2])
            dark = NODE_RE.findall(cols[3])
            size = cols[4] if len(cols) > 4 else ''
            rows.append((sid, name, light, dark, size))
            for ln in light:
                by_node.setdefault(ln, []).append({
                    'id': sid, 'name': name,
                    'dark': dark[0] if dark else None,
                    'size': size,
                })
    return by_node, rows


# --------------------------- png_ref ---------------------------

def png_index():
    """png_ref/ fayllarini (nodeId, tema) bo'yicha indekslaydi."""
    idx = {}
    for p in glob.glob(os.path.join(PNG_REF, '*.jpg')):
        base = os.path.basename(p)
        node = base.split('__', 1)[0]
        theme = 'dark' if base.endswith('__dark.jpg') else 'light'
        idx[(node, theme)] = 'design/figma/png_ref/' + base
    return idx


# --------------------------- daraxt ---------------------------

def visible_children(n):
    """hidden:true bo'lmagan bolalarni qaytaradi."""
    return [c for c in n.get('c', []) if not c.get('hidden')]


def is_icon_subtree(n):
    """Tugun faqat vektor primitivlaridan iborat ikonka konteyneri ekanini aniqlaydi."""
    kids = visible_children(n)
    if not kids:
        return False
    stack = list(kids)
    count = 0
    while stack:
        k = stack.pop()
        t = k.get('t')
        if t == 'TEXT':
            return False
        if t in PRIMITIVES:
            count += 1
        elif t in ('GROUP', 'FRAME', 'INSTANCE'):
            if not visible_children(k):
                return False
        else:
            return False
        stack.extend(visible_children(k))
    return count >= 2


def subtree_size(n):
    """Ko'rinadigan tugunlar sonini sanaydi."""
    return 1 + sum(subtree_size(c) for c in visible_children(n))


def node_line(n, depth, hexmap, root=False):
    """Bitta tugunni spetsifikatsiyadagi bitta qatorga aylantiradi."""
    head = '  ' * depth + (n.get('n') or '?')[:NAME_LEN] + ' [%s]' % n.get('t', '')
    if n.get('w') is not None:
        head += ' %sx%s' % (num(n['w']), num(n['h']))
    if not root and n.get('x') is not None:
        head += ' @%s,%s' % (num(n['x']), num(n['y']))

    seg = []
    if n.get('lay'):
        s = 'AL:' + n['lay'][:1]
        if n.get('gap'):
            s += ' gap' + num(n['gap'])
        pad = n.get('pad')
        if pad and any(pad):
            s += ' pad(%s)' % ','.join(num(v) for v in pad)
        if n.get('align'):
            s += ' ' + '/'.join(str(a) for a in n['align'] if a)
        if n.get('size'):
            s += ' ' + '/'.join(str(a)[0] for a in n['size'])
        seg.append(s)
    if n.get('r'):
        seg.append('r' + num(n['r']))
    for f in (n.get('fill') or [])[:2]:
        seg.append('fill ' + paint_str(hexmap, f))
    for s in (n.get('stroke') or [])[:1]:
        seg.append('stroke ' + paint_str(hexmap, s)
                   + (' w' + num(n.get('sw')) if n.get('sw') else ''))
    if n.get('op') is not None:
        seg.append('op' + num(n['op']))
    for e in (n.get('fx') or [])[:1]:
        seg.append('fx %s r%s' % (e.get('t'), num(e.get('r'))))
    if n.get('t') == 'TEXT':
        txt = (n.get('txt') or '').replace('\n', ' / ')[:30]
        seg.append('"%s" %s/%s' % (txt, num(n.get('fs')), n.get('lh')))

    return head + (' | ' + ' | '.join(seg) if seg else '')


def strip_pos(line):
    """Takroriy satrlarni aniqlash uchun @x,y ni olib tashlaydi."""
    return re.sub(r'@[-\d.]+,[-\d.]+', '@', line)


def build_tree(root, hexmap, maxdepth):
    """Butun daraxtni qatorlarga aylantiradi (hidden shoxlarsiz, ikonka/takror siqilgan)."""
    out = []

    def walk(n, depth, is_root=False):
        """Rekursiv chizuvchi."""
        line = node_line(n, depth, hexmap, root=is_root)
        kids = visible_children(n)
        if not is_root and kids and is_icon_subtree(n):
            out.append(line + ' | ... ikonka: %d primitiv' % (subtree_size(n) - 1))
            return
        out.append(line)
        if not kids:
            return
        if depth >= maxdepth:
            out.append('  ' * (depth + 1)
                       + '... +%d tugun (chuqurlik cheklovi)' % sum(subtree_size(k) for k in kids))
            return
        i = 0
        while i < len(kids):
            base = strip_pos(node_line(kids[i], depth + 1, hexmap))
            j = i + 1
            while j < len(kids) and strip_pos(node_line(kids[j], depth + 1, hexmap)) == base:
                j += 1
            same = j - i
            if same >= 3:
                walk(kids[i], depth + 1)
                out.append('  ' * (depth + 1) + '... x%d bir xil satr (@x,y farq qiladi)' % (same - 1))
            else:
                for k in kids[i:j]:
                    walk(k, depth + 1)
            i = j

    walk(root, 0, is_root=True)
    return out


# --------------------------- matn tugunlari ---------------------------

def split_font(font):
    """`Plus Jakarta Sans Medium` -> (`Plus Jakarta Sans`, `Medium`)."""
    if not font:
        return ('-', '-')
    for st in FONT_STYLES:
        if font.endswith(' ' + st):
            return (font[: -len(st) - 1], st)
    return (font, 'Regular')


def collect_texts(root):
    """Ko'rinadigan TEXT tugunlarini hujjat tartibida yig'adi."""
    out = []

    def walk(n):
        """Rekursiv yig'uvchi."""
        if n.get('t') == 'TEXT':
            out.append(n)
        for c in visible_children(n):
            walk(c)

    walk(root)
    return out


def text_table(texts, hexmap):
    """Matn tugunlari markdown jadvalini quradi."""
    rows = ['| # | Matn | Font oilasi | W | Size | LH | LS | Rang (token) | Align | x,y | wxh |',
            '|---|---|---|---|---|---|---|---|---|---|---|']
    for i, n in enumerate(texts, 1):
        fam, weight = split_font(n.get('font'))
        txt = (n.get('txt') or '').replace('\n', ' / ')
        if len(txt) > TXT_LEN:
            txt = txt[:TXT_LEN] + '...'
        fills = n.get('fill') or []
        color = paint_str(hexmap, fills[0]) if fills else '-'
        al = n.get('al') or []
        rows.append('| %d | %s | %s | %s | %s | %s | %s | %s | %s | %s,%s | %sx%s |' % (
            i, md_cell(txt), md_cell(fam), weight, num(n.get('fs')), n.get('lh'),
            num(n.get('ls')), md_cell(color), '/'.join(al),
            num(n.get('x')), num(n.get('y')), num(n.get('w')), num(n.get('h'))))
    return rows


# --------------------------- o'lchovlar va ogohlantirishlar ---------------------------

def measure(root):
    """Ko'rinadigan tugunlardan radius/gap/pad/stroke/fontSize chastotalarini yig'adi."""
    m = {'r': Counter(), 'gap': Counter(), 'padH': Counter(), 'padV': Counter(),
         'sw': Counter(), 'fs': Counter(), 'font': Counter(),
         'fill': Counter(), 'stroke': Counter()}

    def walk(n):
        """Rekursiv o'lchovchi."""
        if n.get('r'):
            m['r'][num(n['r'])] += 1
        if n.get('gap'):
            m['gap'][num(n['gap'])] += 1
        pad = n.get('pad')
        if pad and any(pad):
            m['padV'][num(pad[0])] += 1
            m['padH'][num(pad[1])] += 1
            m['padV'][num(pad[2])] += 1
            m['padH'][num(pad[3])] += 1
        if n.get('sw'):
            m['sw'][num(n['sw'])] += 1
        if n.get('t') == 'TEXT':
            m['fs'][n.get('fs')] += 1
            m['font'][n.get('font')] += 1
        for f in n.get('fill') or []:
            m['fill'][f] += 1
        for s in n.get('stroke') or []:
            m['stroke'][s] += 1
        for c in visible_children(n):
            walk(c)

    walk(root)
    return m


def hist_line(counter, limit=12):
    """Counter ni `8x56, 4x30` ko'rinishida beradi."""
    if not counter:
        return '-'
    items = sorted(counter.items(), key=lambda kv: (-kv[1], str(kv[0])))[:limit]
    return ', '.join('%sx%d' % (k, v) for k, v in items)


def off_grid(v):
    """Qiymat butun emas yoki 4 ga ham 5 ga ham karrali emasligini tekshiradi."""
    try:
        f = float(v)
    except (TypeError, ValueError):
        return False
    if abs(f - round(f)) > 1e-6:
        return True
    i = int(round(f))
    return i != 0 and i % 5 != 0 and i % 4 != 0


def warnings(m, hexmap, tk):
    """Ogohlantirishlar ro'yxatini quradi."""
    w = []
    frac_fs = dict((k, v) for k, v in m['fs'].items()
                   if isinstance(k, float) and abs(k - round(k)) > 1e-6)
    if frac_fs:
        w.append("**Butun bo'lmagan fontSize** (masshtab izi): "
                 + hist_line(Counter(dict((num(k), v) for k, v in frac_fs.items()))))

    no_tok = Counter()
    for src in ('fill', 'stroke'):
        for paint, cnt in m[src].items():
            if isinstance(paint, str) and paint.startswith('#') and not token_of(hexmap, paint):
                no_tok[paint.split('/')[0].upper()] += cnt
    if no_tok:
        w.append("**tokens.json da yo'q ranglar** (%d ta): %s" % (len(no_tok), hist_line(no_tok, 10)))

    grid = Counter()
    for key in ('gap', 'padH', 'padV'):
        for v, c in m[key].items():
            if off_grid(v):
                grid[v] += c
    if grid:
        w.append("**4/5 ga karrali bo'lmagan spacing**: " + hist_line(grid, 10))

    fams = set(split_font(f)[0] for f in m['font'] if f)
    known = set((tk.get('typography') or {}).get('_families') or [])
    alien = sorted(fams - known)
    if alien:
        w.append("**tokens.json tipografikasida yo'q shrift oilasi**: " + ', '.join(alien))

    radii = sorted(k for k in m['r'] if off_grid(k))
    if radii:
        w.append("**standart bo'lmagan cornerRadius**: " + ', '.join(radii))
    return w


# --------------------------- karta ---------------------------

def code_file(screen_id):
    """Ekran ID uchun lib/ dagi mavjud ekran faylini qaytaradi (yo'q bo'lsa None)."""
    mo = re.match(r'^([MT]-\d+)', screen_id or '')
    if not mo:
        return None
    rel = CODE_MAP.get(mo.group(1))
    if not rel:
        return None
    return 'lib/features/' + rel if os.path.exists(os.path.join(MOBILE, 'lib', 'features', rel)) else None


def render_card(path, maps, pngs, hexmap, tk, depth):
    """Bitta ekran JSON'idan spec karta matnini va meta ma'lumotini quradi."""
    with open(path, encoding='utf-8') as fh:
        root = json.load(fh)
    node = root.get('id') or colon_id(os.path.basename(path).split('__')[0])
    entries = maps.get(node) or []
    ids = '/'.join(OrderedDict((e['id'], 1) for e in entries)) or 'UNMAPPED'
    tz_name = entries[0]['name'] if entries else '-'
    dark = entries[0]['dark'] if entries else None

    png_l = pngs.get((dash_id(node), 'light'))
    png_d = pngs.get((dash_id(node), 'dark'))
    if not png_d and dark:
        png_d = pngs.get((dash_id(dark), 'dark'))

    texts = collect_texts(root)
    m = measure(root)
    warn = warnings(m, hexmap, tk)
    cf = code_file(entries[0]['id'] if entries else '')
    raw_kb = os.path.getsize(path) // 1024

    head = [
        '# %s - %s' % (ids, root.get('n')),
        '',
        '> TZ nomi: **%s** - xom JSON: `design/figma/screens/%s` (%d KB). '
        'Bu karta o\'sha JSON o\'rniga o\'qiladi.' % (tz_name, os.path.basename(path), raw_kb),
        '',
        '| Maydon | Qiymat |',
        '|---|---|',
        '| Ekran ID | `%s` |' % ids,
        '| Figma freym nomi | `%s` |' % root.get('n'),
        '| nodeId light | `%s` |' % node,
        '| nodeId dark | %s |' % ('`%s`' % dark if dark else "- (dark juftligi yo'q)"),
        "| Freym o'lchami | %sx%s dp |" % (num(root.get('w')), num(root.get('h'))),
        '| Fon (root fill) | %s |' % paint_str(hexmap, (root.get('fill') or ['-'])[0]),
        '| png_ref light | %s |' % ('`%s`' % png_l if png_l else '-'),
        '| png_ref dark | %s |' % ('`%s`' % png_d if png_d else '-'),
        '| Kod fayli | %s |' % ('`%s`' % cf if cf else '-'),
        "| Ko'rinadigan tugun | %d (shundan TEXT: %d) |" % (subtree_size(root), len(texts)),
        '',
    ]

    legend = [
        '## 1. Layout daraxti',
        '',
        'Format: `nom [tur] WxH @x,y | AL:V gap10 pad(T,R,B,L) MIN/CENTER F/H | r8 | '
        'fill #FFFFFF (token) | stroke #E5E7EB w1`',
        '',
        "- `hidden:true` shoxlar **butunlay** tashlab yuborilgan.",
        "- `pad(T,R,B,L)` - Figma paddingTop/Right/Bottom/Left. `F/H` - layoutSizing (Fixed/Hug/Fill).",
        "- Rang tokeni `tokens.json` dan; topilmasa `(TOKEN YO'Q)`. Rang/spacing rasmdan o'lchanmaydi.",
        "- Faqat vektor primitivlaridan iborat shoxlar `... ikonka: N primitiv` deb siqilgan.",
        '',
    ]

    def body(d):
        """Berilgan chuqurlik uchun to'liq karta matni."""
        parts = list(head) + list(legend) + ['Chuqurlik: %d.' % d, '', '```']
        parts += build_tree(root, hexmap, d)
        parts += ['```', '', '## 2. Matn tugunlari', '']
        parts += text_table(texts, hexmap)
        parts += [
            '',
            "## 3. O'lchov xulosasi",
            '',
            '| Parametr | Qiymatlar (qiymat x soni) |',
            '|---|---|',
            '| cornerRadius | %s |' % hist_line(m['r']),
            '| gap (itemSpacing) | %s |' % hist_line(m['gap']),
            '| padding gorizontal (R,L) | %s |' % hist_line(m['padH']),
            '| padding vertikal (T,B) | %s |' % hist_line(m['padV']),
            '| strokeWeight | %s |' % hist_line(m['sw']),
            '| fontSize | %s |' % hist_line(Counter(dict((num(k), v) for k, v in m['fs'].items()))),
            '',
            '## 4. Ogohlantirishlar',
            '',
        ]
        parts += (['- ' + x for x in warn] if warn else ["- Yo'q."])
        parts.append('')
        return '\n'.join(parts)

    text = body(depth)
    used = depth
    while len(text.encode('utf-8')) > MAX_BYTES and used > 2:
        used -= 1
        text = body(used)
    if used != depth:
        text = text.replace('Chuqurlik: %d.' % used,
                            'Chuqurlik: %d (8 KB chegarasi sababli %d dan qisqartirildi).' % (used, depth))

    meta = {'id': ids, 'name': root.get('n'), 'tz': tz_name, 'node': node, 'dark': dark,
            'png_l': png_l, 'png_d': png_d, 'code': cf,
            'size': '%sx%s' % (num(root.get('w')), num(root.get('h'))),
            'bytes': len(text.encode('utf-8'))}
    return text, meta


def spec_name(meta):
    """Spec fayl nomi: `<M-ID>__<nodeId>.md`."""
    sid = re.sub(r'[^A-Za-z0-9._-]', '_', meta['id'])
    return '%s__%s.md' % (sid, dash_id(meta['node']))


def sort_key(meta):
    """INDEX ni ekran ID bo'yicha tabiiy tartiblash."""
    mo = re.match(r'^([MT])-(\d+)(.*)$', meta['id'])
    if not mo:
        return (2, '', 999, '', meta['node'])
    return (0 if mo.group(1) == 'M' else 1, mo.group(1), int(mo.group(2)), mo.group(3), meta['node'])


def write_index(metas):
    """spec/INDEX.md ni yozadi."""
    lines = [
        '# Spec kartalar indeksi',
        '',
        'Jami **%d** karta - generator: `python3 tool/figma_speccard.py --all --index`.' % len(metas),
        '',
        "Ekran ustida ishlashdan oldin **faqat** o'z ekraningizning spec kartasini o'qing -",
        "`design/figma/screens/*.json` xom fayllari ochilmaydi.",
        "Etalon rasm faqat `design/figma/png_ref/` dan, har biri **bir marta**.",
        '',
        '| Ekran ID | Figma nomi | nodeId light | nodeId dark | Spec | png_ref light | png_ref dark | Kod fayli |',
        '|---|---|---|---|---|---|---|---|',
    ]
    for m in sorted(metas, key=sort_key):
        lines.append('| %s | %s | `%s` | %s | [%s](%s) | %s | %s | %s |' % (
            m['id'], md_cell(m['name']), m['node'],
            '`%s`' % m['dark'] if m['dark'] else '-',
            spec_name(m), spec_name(m),
            '`%s`' % os.path.basename(m['png_l']) if m['png_l'] else '-',
            '`%s`' % os.path.basename(m['png_d']) if m['png_d'] else '-',
            '`%s`' % m['code'] if m['code'] else '-'))
    lines += ['', "`png_ref` to'liq yo'li: `design/figma/png_ref/<fayl>`.", '']
    with open(os.path.join(SPEC, 'INDEX.md'), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(lines))


def main():
    """CLI kirish nuqtasi: --all / <nodeId> / --index."""
    ap = argparse.ArgumentParser(description='Figma ekran JSON -> spec karta')
    ap.add_argument('node', nargs='?', help='nodeId (958:44 yoki 958-44)')
    ap.add_argument('--all', action='store_true', help='hamma ekranni generatsiya qilish')
    ap.add_argument('--index', action='store_true', help='spec/INDEX.md ni yozish')
    ap.add_argument('--depth', type=int, default=DEFAULT_DEPTH,
                    help='daraxt chuqurligi (default %d)' % DEFAULT_DEPTH)
    a = ap.parse_args()
    if not (a.all or a.node or a.index):
        ap.error("--all, --index yoki <nodeId> ko'rsating")

    os.makedirs(SPEC, exist_ok=True)
    tk, hexmap = load_tokens()
    maps, _ = parse_map()
    pngs = png_index()

    files = sorted(glob.glob(os.path.join(SCREENS, '*.json')))
    if a.node and not a.all:
        key = dash_id(a.node)
        files = [p for p in files if os.path.basename(p).split('__')[0] == key]
        if not files:
            sys.exit('topilmadi: %s' % a.node)

    metas = []
    for p in files:
        text, meta = render_card(p, maps, pngs, hexmap, tk, a.depth)
        out = os.path.join(SPEC, spec_name(meta))
        with open(out, 'w', encoding='utf-8') as fh:
            fh.write(text)
        metas.append(meta)
        print('%5d B  %s' % (meta['bytes'], os.path.relpath(out, MOBILE)))

    if a.index:
        write_index(metas)
        print('INDEX: design/figma/spec/INDEX.md (%d qator)' % len(metas))


if __name__ == '__main__':
    main()

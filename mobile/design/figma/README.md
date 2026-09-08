# Figma etalon manbai

Bu papka — UI ning **yagona vizual haqiqat manbai**. `screen-implementer` har ekranni
shu yerdagi qiymatlar bo'yicha yozadi; `tz-mobile.md` dagi matnli tavsif bilan ziddiyat
bo'lsa — **Figma kanonik**, ziddiyat `DIFF.md` ga yoziladi va TZ ga CR qilinadi.

Manba: Figma fayl `ELD Software (Copy)` · fileKey `NLDjNYebjCuNswunequFv2`
Sahifalar: Branding & Color `14:2` · Mobile Application `14:6` (Light `1070:6813`, Dark `2665:25648`) ·
Tablet Application `14:7` (Light `1470:21013`, Dark `2197:104566` — **faqat shu ikkisi ko'rinadi**;
`Home`/`Section 1`/`Section 3` sectionlari `visible:false` = arxiv, ular `exportAsync` da 1×1 qaytaradi)

## Tarkib
| Fayl | Mazmuni |
|---|---|
| `tokens.json` | Ranglar (hex + nom), tipografika (shrift/size/weight/lineHeight/letterSpacing), radius, soya, spacing |
| `MAP.md` | Ekran ID (M-01…M-58, T-01…T-35) → Figma node id → fayl yo'llari |
| `screens/<ID>.json` | Frame o'lchami, tugunlar daraxti: nom, tur, x/y/w/h, auto-layout, padding, gap, fill, stroke, radius, text style, matn qiymati |
| `png/<ID>-light.png`, `png/<ID>-dark.png` | Vizual etalon rasmlar (mobil, @2x) |
| `png_ref/<nodeId>__<nom>__<tema>.jpg` | Yengil etalon (maks 1000 px, JPEG q62). Planshet: `<nodeId>__<T-ID>__<nom>__<tema>.jpg` |
| `DIFF.md` | Figma ↔ `design-inventory.md` ↔ `tz-mobile.md` farqlari va qabul qilingan qaror |

## O'qish — `tool/figma_spec.py` [MUST]

`screens/*.json` xom fayllari **32–96 KB, bir qatorli**. Ularni to'liq o'qish taqiqlanadi.
```
python3 tool/figma_spec.py --list                     # mavjud ekranlar
python3 tool/figma_spec.py <nodeId> --depth 3         # umumiy tuzilma (~1 KB)
python3 tool/figma_spec.py <nodeId> --find "App Bar" --depth 4
python3 tool/figma_spec.py <nodeId> --text            # matn: font/size/lineHeight/rang
```
Har tugun bitta qator: `nom [tur] WxH @x,y Vgap15pad[...] MIN/CENTER r8 fill['#FFF'] str[...]@1 "matn" Font 14/20`.

## Chiqarish (`figma-extractor` agenti)
Old shart: Figma Desktop ochiq · `ELD Software (Copy)` fayli ochiq ·
`Plugins → Development → Figma Desktop Bridge` oynasi ochiq · `figma-console` MCP ulangan.

`figma_execute` ichida **avval** `await figma.loadAllPagesAsync()`.
PNG: `node.exportAsync({format:'PNG'})` → base64 → diskka (bir chaqiruvda 5–8 tugun).
`figma_take_screenshot` **ishlatilmaydi** — rasm kontekstni yeydi.

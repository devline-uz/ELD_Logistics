# UNMAPPED - Eac row (on-click)

> TZ nomi: **-** - xom JSON: `design/figma/screens/1166-504__Eac_row_on-click.json` (51 KB). Bu karta o'sha JSON o'rniga o'qiladi.

| Maydon | Qiymat |
|---|---|
| Ekran ID | `UNMAPPED` |
| Figma freym nomi | `Eac row (on-click)` |
| nodeId light | `1166:504` |
| nodeId dark | - (dark juftligi yo'q) |
| Freym o'lchami | 393x852 dp |
| Fon (root fill) | #FFFFFF (white) |
| png_ref light | `design/figma/png_ref/1166-504__Eac_row_on-click__light.jpg` |
| png_ref dark | - |
| Kod fayli | - |
| Ko'rinadigan tugun | 314 (shundan TEXT: 76) |

## 1. Layout daraxti

Format: `nom [tur] WxH @x,y | AL:V gap10 pad(T,R,B,L) MIN/CENTER F/H | r8 | fill #FFFFFF (token) | stroke #E5E7EB w1`

- `hidden:true` shoxlar **butunlay** tashlab yuborilgan.
- `pad(T,R,B,L)` - Figma paddingTop/Right/Bottom/Left. `F/H` - layoutSizing (Fixed/Hug/Fill).
- Rang tokeni `tokens.json` dan; topilmasa `(TOKEN YO'Q)`. Rang/spacing rasmdan o'lchanmaydi.
- Faqat vektor primitivlaridan iborat shoxlar `... ikonka: N primitiv` deb siqilgan.

Chuqurlik: 2 (8 KB chegarasi sababli 5 dan qisqartirildi).

```
Eac row (on-click) [FRAME] 393x852 | fill #FFFFFF (white)
  Frame 188 [FRAME] 393x1421 @0,121 | AL:V gap15 MIN/CENTER F/F
    Banner [FRAME] 343x180 @25,0
      ... +16 tugun (chuqurlik cheklovi)
    Frame 187 [FRAME] 345x1199 @24,195 | AL:V gap20 MIN/CENTER F/F
      ... +170 tugun (chuqurlik cheklovi)
  App Bar [FRAME] 393x54 @0,60 | AL:H gap244 pad(12,21,12,21) SPACE_BETWEEN/CENTER F/H | fill #C2C1CD/0.20 (overlay)
    Frame 39358 [FRAME] 127x30 @21,12 | AL:H gap15 MIN/CENTER H/H
      ... +1 tugun (chuqurlik cheklovi)
    Frame 1321317336 [FRAME] 97x24 @275,15 | AL:H gap15 CENTER/CENTER F/H | ... ikonka: 10 primitiv
  BNB-19 [FRAME] 393x94 @0,758 | AL:H gap59 SPACE_BETWEEN/MIN F/H | fill #FFFFFF (white) | stroke #E5E7EB (stroke) | fx INNER_SHADOW r1
    navigation/menu - home [FRAME] 101x94 @0,0 | AL:V gap6 pad(20,25.5,20,25.5) CENTER/CENTER H/H
      ... +4 tugun (chuqurlik cheklovi)
    navigation/menu - wallet [FRAME] 75x75 @123.33,0 | AL:V gap10 pad(25.5,25.5,25.5,25.5) MIN/CENTER H/H
      ... +2 tugun (chuqurlik cheklovi)
    navigation/menu - analysis [FRAME] 75x75 @220.67,0 | AL:V gap10 pad(25.5,25.5,25.5,25.5) CENTER/CENTER H/H | ... ikonka: 4 primitiv
    navigation/menu - home [FRAME] 75x75 @318,0 | AL:V gap10 pad(25.5,25.5,25.5,25.5) CENTER/CENTER H/H | ... ikonka: 6 primitiv
  Rectangle 156392 [RECTANGLE] 394x852 @0,0 | fill #000314/0.40 (ink)
  Frame 1321317366 [FRAME] 345x534 @24,159 | AL:H gap10 pad(20,20,20,20) MIN/CENTER F/H | r8 | fill #FFFFFF (white) | stroke #E5E7EB (stroke) w1
    Frame 1321317365 [FRAME] 301x494 @20,20 | AL:V gap15 MIN/MIN F/H
      ... +67 tugun (chuqurlik cheklovi)
    oui:cross [FRAME] 16x16 @305,20
      ... +1 tugun (chuqurlik cheklovi)
  Status Bar [FRAME] 393x59 @0,0 | AL:H CENTER/CENTER F/F
    Time [FRAME] 131x59 @0,0 | AL:H CENTER/CENTER F/F
      ... +2 tugun (chuqurlik cheklovi)
    Dynamic Island Frame [FRAME] 131x59 @131,0 | AL:H CENTER/CENTER F/F
    Icons [FRAME] 131x59 @262,0 | AL:H gap8 CENTER/CENTER F/F | ... ikonka: 11 primitiv
```

## 2. Matn tugunlari

| # | Matn | Font oilasi | W | Size | LH | LS | Rang (token) | Align | x,y | wxh |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Driver Name | Satoshi Variable | Bold | 16 | 22 | 0 | #FCFCFD (bgLight) | LEFT/TOP | 0,0 | 111x18 |
| 2 | Off-duty | Satoshi Variable | Medium | 14 | 22 | 0 | #30B0C7 (decorative.teal) | LEFT/CENTER | 17,4 | 60x20 |
| 3 | Unit Number: | Satoshi Variable | Medium | 12 | 16 | 0 | #D6D8E0 (neutral.4) | LEFT/TOP | 0,0 | 75x29 |
| 4 | 1021 | Satoshi Variable | Medium | 12 | 16 | 0 | #E6E8EC (neutral.3) | LEFT/TOP | 80,0 | 27x29 |
| 5 | ELD . Not connected | MIXED | Regular | MIXED | 18 | 0 | #FCFCFD (bgLight) | LEFT/TOP | 35.5,5 | 118x22 |
| 6 | Categories | Plus Jakarta Sans | Bold | 16 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 1,0 | 111x17 |
| 7 | DOT Report | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | CENTER/TOP | 0,29 | 78x15 |
| 8 | Co-driver | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | CENTER/TOP | -11,29 | 60x15 |
| 9 | User Manual | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | CENTER/TOP | -21,29 | 82x15 |
| 10 | Leave Truck | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | CENTER/TOP | -21,29 | 78x15 |
| 11 | Hours of Service  | Plus Jakarta Sans | Bold | 16 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 1,0 | 161x17 |
| 12 | 08:00 | Satoshi Variable | Bold | 14 | AUTO | 0 | #36454F (TOKEN YO'Q) | LEFT/TOP | 16,20 | 43x19 |
| 13 | BREAK | Satoshi Variable | Regular | 12 | AUTO | 0 | #D97D28 (state.warning.strong) | LEFT/TOP | 18.5,39 | 38x16 |
| 14 | 09:00 | Satoshi Variable | Bold | 14 | AUTO | 0 | #36454F (TOKEN YO'Q) | LEFT/TOP | 16,20 | 43x19 |
| 15 | DRIVE | Satoshi Variable | Regular | 12 | AUTO | 0 | #358D0C (state.success.strong) | LEFT/TOP | 20.5,39 | 34x16 |
| 16 | 10:00 | Satoshi Variable | Bold | 14 | AUTO | 0 | #36454F (TOKEN YO'Q) | LEFT/TOP | 17.5,20 | 40x19 |
| 17 | SHIFT | Satoshi Variable | Regular | 12 | AUTO | 0 | #007AFF (TOKEN YO'Q) | LEFT/TOP | 21.5,39 | 32x16 |
| 18 | 65:00 | Satoshi Variable | Bold | 14 | AUTO | 0 | #36454F (TOKEN YO'Q) | LEFT/TOP | 16.5,20 | 42x19 |
| 19 | CYCLE | Satoshi Variable | Regular | 12 | AUTO | 0 | #B7002C (primary) | LEFT/TOP | 19,39 | 37x16 |
| 20 | On Duty | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #777E90 (neutral.6) | CENTER/TOP | 0,29 | 71x18 |
| 21 | Sleep | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #777E90 (neutral.6) | CENTER/TOP | 0,29 | 71x18 |
| 22 | Off-duty | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #FCFCFD (bgLight) | CENTER/TOP | 0,29 | 71x18 |
| 23 | 10:45 23 | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #FCFCFD (bgLight) | CENTER/TOP | 0,0 | 52x15 |
| 24 | Trip Details | Plus Jakarta Sans | Bold | 16 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 1,0 | 161x17 |
| 25 | Shipping Doc | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | LEFT/TOP | 0,0 | 121x15 |
| 26 | N/A | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,20 | 121x18 |
| 27 | Trailer Number | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | LEFT/TOP | 0,0 | 133x15 |
| 28 | N/A | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,20 | 133x18 |
| 29 | Notes | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | LEFT/TOP | 0,0 | 89x15 |
| 30 | Lorem ipsum | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,20 | 89x18 |
| 31 | Signature | Plus Jakarta Sans | Bold | 16 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 1,0 | 161x17 |
| 32 | Certify | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #777E90 (neutral.6) | LEFT/TOP | 0,0 | 133x15 |
| 33 | Not Signed | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #E2464A (state.error.base) | LEFT/TOP | 0,20 | 133x18 |
| 34 | Log | Plus Jakarta Sans | Bold | 16 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 1,0 | 161x17 |
| 35 | OFF | Inter | Medium | 5 | 22 | 0 | #B1B5C3 (neutral.5) | LEFT/TOP | 0.5,0 | 12x14 |
| 36 | SB | Inter | Medium | 5 | 22 | 0 | #B1B5C3 (neutral.5) | LEFT/TOP | 1,18 | 11x14 |
| 37 | DR | Inter | Medium | 5 | 22 | 0 | #B1B5C3 (neutral.5) | LEFT/TOP | 1,36 | 11x14 |
| 38 | ON | Inter | Medium | 5 | 22 | 0 | #B1B5C3 (neutral.5) | LEFT/TOP | 0,54 | 13x14 |
| 39 | OFF  03:06  | Plus Jakarta Sans | Medium | 10 | AUTO | -0.3 | #30B0C7 (decorative.teal) | LEFT/TOP | 34.5,0 | 51x13 |
| 40 | SB  00:00 | Plus Jakarta Sans | Medium | 10 | AUTO | -0.3 | #F6BA47 (state.warning.base) | LEFT/TOP | 105.5,0 | 47x13 |
| 41 | DR  00:00  | Plus Jakarta Sans | Medium | 10 | AUTO | -0.3 | #2FA766 (state.success.base) | LEFT/TOP | 172.5,0 | 47x13 |
| 42 | ON  00:00 | Plus Jakarta Sans | Medium | 10 | AUTO | -0.3 | #EE4E68 (decorative.pink) | LEFT/TOP | 239.5,0 | 50x13 |
| 43 | Status | Plus Jakarta Sans | Medium | 10 | AUTO | -0.3 | #F4F5F6 (neutral.2) | LEFT/TOP | 0,0 | 89x13 |
| 44 | Start Time | Plus Jakarta Sans | Medium | 10 | AUTO | -0.3 | #F4F5F6 (neutral.2) | LEFT/TOP | 0,0 | 89x13 |
| 45 | Location | Plus Jakarta Sans | Medium | 10 | AUTO | -0.3 | #F4F5F6 (neutral.2) | LEFT/TOP | 0,0 | 125x13 |
| 46 | ON | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #FCFCFD (bgLight) | LEFT/TOP | 7.5,4 | 20x15 |
| 47 | 02:24:54 PM | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 89x18 |
| 48 | 3.40 mi  West of .... | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 49 | DR | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #FCFCFD (bgLight) | LEFT/TOP | 9,4 | 17x15 |
| 50 | 02:24:54 PM | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 89x18 |
| 51 | 3.40 mi  West of .... | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 52 | ON | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #FCFCFD (bgLight) | LEFT/TOP | 7.5,4 | 20x15 |
| 53 | 02:24:54 PM | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 89x18 |
| 54 | 3.40 mi  West of .... | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 55 | SB | Plus Jakarta Sans | Medium | 12 | AUTO | -0.3 | #FCFCFD (bgLight) | LEFT/TOP | 9.5,4 | 16x15 |
| 56 | 02:24:54 PM | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 89x18 |
| 57 | 3.40 mi  West of .... | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 58 | OneBook ELD | MIXED | Regular | 19 | 160% | 0.15 | - | LEFT/CENTER | 0,0 | 127x30 |
| 59 | Home | Satoshi Variable | Bold | 14 | AUTO | 0 | #1C1E24 (neutral.10) | LEFT/TOP | 31,55 | 39x19 |
| 60 | Report Details | Plus Jakarta Sans | Bold | 16 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 301x17 |
| 61 | Time | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #777E90 (neutral.6) | LEFT/TOP | 0,0 | 125x18 |
| 62 | May 20, Tue | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 63 | Location | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #777E90 (neutral.6) | LEFT/TOP | 0,0 | 125x18 |
| 64 | Lorem ipsum | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 65 | Odometer | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #777E90 (neutral.6) | LEFT/TOP | 0,0 | 125x18 |
| 66 | 1000 | Plus Jakarta Sans | Medium | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 67 | Truck defects | Plus Jakarta Sans | SemiBold | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 68 | Clutch | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 41x20 |
| 69 | Engine | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 42x20 |
| 70 | Battery | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 45x20 |
| 71 | Exhaust | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 48x20 |
| 72 | Trailer defects | Plus Jakarta Sans | SemiBold | 14 | AUTO | -0.3 | #1C1E24 (neutral.10) | LEFT/TOP | 0,0 | 125x18 |
| 73 | Brakes | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 41x20 |
| 74 | Doors | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 37x20 |
| 75 | Hitch | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 33x20 |
| 76 | Other | Product Sans | Regular | 14 | 20 | 0 | #1C1E24 (neutral.10) | LEFT/CENTER | 34,2 | 37x20 |

## 3. O'lchov xulosasi

| Parametr | Qiymatlar (qiymat x soni) |
|---|---|
| cornerRadius | 8x12, 4x5, 6x4, 10x2, 12x2, 17x2, 5x1, [0, 0, 8, 8]x1, [5, 5, 0, 5]x1 |
| gap (itemSpacing) | 10x44, 5x38, 15x9, 8x9, 20x3, 11x2, 6x2, 16x1, 244x1, 25x1, 4x1, 59x1 |
| padding gorizontal (R,L) | 10x22, 0x10, 15.74x8, 20x8, 25.5x8, 5x8, 7x4, 15x2, 21x2 |
| padding vertikal (T,B) | 10x12, 20x12, 0x10, 13.41x8, 4x8, 25.5x6, 15x4, 5x4, 7x4, 12x2, 17x2 |
| strokeWeight | 1x31, 1.5x6, 0.5x1, 0.73x1, 1.06x1, 3x1 |
| fontSize | 14x37, 12x19, 10x7, 16x7, 5x4, 19x1, MIXEDx1 |

## 4. Ogohlantirishlar

- **tokens.json da yo'q ranglar** (8 ta): #000000x9, #36454Fx4, #D9D9D9x4, #007AFFx3, #BE2928x2, #2B2B2Bx1, #514F4Fx1, #D30202x1
- **4/5 ga karrali bo'lmagan spacing**: 25.5x14, 7x9, 13.41x8, 15.74x8, 11x2, 17x2, 21x2, 6x2, 59x1
- **tokens.json tipografikasida yo'q shrift oilasi**: Inter, MIXED, Plus Jakarta Sans, Satoshi Variable
- **standart bo'lmagan cornerRadius**: 17, 6

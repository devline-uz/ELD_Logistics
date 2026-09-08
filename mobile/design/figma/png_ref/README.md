# png_ref/ — kontekstga arzon Figma etalonlari

`png/` dagi 138 ta @2x PNG (17 MB, ba'zi fayllar 680 KB) dan avtomatik olingan
siqilgan nusxa: **maks 1000 px, JPEG q62, jami 4.8 MB, o'rtacha 35 KB**.

## Nega kerak
Subagent rasmni o'qiganda u base64 sifatida kontekstga tushadi va **keyingi har bir
API so'rovida qayta yuboriladi**. O'lchov: bitta agent 167 tool chaqiruvida 2 MB
tool natijasi to'plagan, shundan 559 KB — **bitta** PNG. Bir nechta etalon o'qigan
agent shu sababli 300k+ token sarflaydi.

## Qoida [MUST]
- Ekran etaloni kerak bo'lsa **`png_ref/` dan o'qi**, `png/` dan emas.
- Har etalonni **bir marta** o'qi. Qayta o'qish = to'liq narxni qayta to'lash.
- Faqat o'zing yozayotgan ekranning etalonini o'qi.
- Aniq qiymatlar (rang, spacing, radius, tipografika) rasmdan **o'lchanmaydi** —
  ular `tokens.json` va `MAP.md` da. Rasm faqat kompozitsiya uchun.
- `png/` (asl @2x) faqat haqiqatan piksel darajasida shubha bo'lganda ochiladi.

## Qayta yaratish
```sh
cd mobile/design/figma
for f in png/*.png; do
  sips -s format jpeg -s formatOptions 62 -Z 1000 "$f" \
       --out "png_ref/$(basename "$f" .png).jpg" >/dev/null
done
```

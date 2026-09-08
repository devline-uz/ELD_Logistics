export default {
  locales: ['en'],
  input: ['src/**/*.{ts,tsx}'],
  output: 'src/locales/$LOCALE.json',
  defaultNamespace: 'translation',
  createOldCatalogs: false,
  // `false` bo'lsa static skaner topmagan (dinamik) kalitlarni o'chirib
  // tashlaydi — bu loyihada `nav-config.ts` (`labelKey`/`descriptionKey`) va
  // `lib/errors.ts` (`ERROR_I18N_KEYS`) orqali ko'plab kalit **dinamik**
  // o'zgaruvchidan chaqiriladi (`t(labelKey)`), parser buni ko'ra olmaydi.
  // `true` — yo'qolgan kalitlarni hali ham qo'shadi, lekin dinamik
  // ishlatiladigan kalitlarni tasodifan o'chirib tashlamaydi.
  keepRemoved: true,
  sort: true,
  indentation: 2,
  keySeparator: '.',
  namespaceSeparator: false,
  lexers: {
    ts: ['JavascriptLexer'],
    tsx: ['JsxLexer'],
  },
};

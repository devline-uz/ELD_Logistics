export default {
  locales: ['en'],
  input: ['src/**/*.{ts,tsx}'],
  output: 'src/locales/$LOCALE.json',
  defaultNamespace: 'translation',
  createOldCatalogs: false,
  keepRemoved: false,
  sort: true,
  indentation: 2,
  keySeparator: '.',
  namespaceSeparator: false,
  lexers: {
    ts: ['JavascriptLexer'],
    tsx: ['JsxLexer'],
  },
};

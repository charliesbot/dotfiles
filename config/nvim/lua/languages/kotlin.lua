-- Kotlin. Using the community kotlin_language_server (mason-installable) as a
-- working baseline. The official JetBrains kotlin-lsp is the eventual target,
-- but it may need a manual cmd rather than a mason install; revisit later.
return {
  server = 'kotlin_language_server',
  parsers = { 'kotlin' },
}

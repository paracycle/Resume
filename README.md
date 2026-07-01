# Resume

Ufuk Kayserilioglu's resume, built with [Typst](https://typst.app), with all
content stored in `data.yml` so it can be edited without touching
layout code.

The most recent PDF version is available
[here](http://ufuk-kayserilioglu-resume.s3.amazonaws.com/main/Ufuk-Kayserilioglu-Resume.pdf).

See `CLAUDE.md` for full context and `docs/schema.md` for the field
reference.

## Files

- `resume.typ` — layout template
- `data.yml` — all CV content (edit this)
- `fonts/` — bundled Fontin `.ttf` files
- `bin/setup` — installs the Typst CLI and `yajsv`
- `bin/validate` — checks `data.yml` against `docs/schema.json`
- `bin/build` — validates `data.yml`, then compiles the resume to a PDF
- `docs/schema.md` — field reference for `data.yml`
- `docs/schema.json` — machine-checkable schema for `data.yml`

## Editing the resume

Open `data.yml` and edit the relevant section. No Typst knowledge
needed for plain text; see `docs/schema.md` if you want to use bold,
italics, or links in a field. `bin/build` validates before compiling, so
a typo in a key name fails with a clear message instead of a cryptic
Typst error.

## Building

Requires the [Typst CLI](https://github.com/typst/typst).

```bash
bin/setup   # one-time: installs typst + yajsv
bin/build   # validates data.yml, then compiles -> Ufuk-Kayserilioglu-Resume.pdf
```

Equivalently, run the compile directly (skips validation):

```bash
typst compile --font-path fonts resume.typ Ufuk-Kayserilioglu-Resume.pdf
```

`--font-path fonts` points Typst at the bundled Fontin `.ttf` files (not
installed system-wide).

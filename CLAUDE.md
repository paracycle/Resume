# CLAUDE.md

Context for Claude Code (or any future Claude session) picking up work on this
repo. This is a personal resume/CV, authored in Typst, with all content
externalized into a YAML data file.

## Project in one sentence

Ufuk Kayserilioglu's resume, originally a LaTeX document, rebuilt in Typst as
a template (`resume.typ`) that renders from a single data file
(`data.yml`) so content edits never require touching layout code.

## Origin / provenance

- Original source: LaTeX resume at https://github.com/paracycle/Resume
  (`Ufuk-Kayserilioglu-Resume.tex`, using the `layaureo`, `supertabular`,
  `booktabs`, `titlesec` packages and custom Fontin fonts).
- Converted to Typst in a Claude.ai chat, then refactored to be data-driven
  from a YAML file in the same conversation. This repo is the continuation
  of that work.
- The PDF output is intended to look essentially identical to the original
  LaTeX version: same section order, same small-caps section headers with a
  rule underneath, same right-aligned date column / left-aligned description
  layout, same page breaks.

## File layout

```
resume.typ          Layout/styling template — should rarely need edits
data.yml            All CV content — edit this for day-to-day updates
fonts/              Bundled Fontin *.ttf files
bin/
  setup                  Installs typst + yajsv (Homebrew, or Linux binaries)
  validate               Checks data.yml against docs/schema.json
  build                  Compiles resume.typ -> the PDF
docs/
  schema.md              Field-by-field reference for data.yml
  schema.json            Machine-checkable JSON Schema for data.yml
README.md            Quick start / build instructions
```

## The core design decision

`resume.typ` loads `data.yml` via Typst's built-in `yaml()` function and
iterates over it with `#for` loops and a handful of small helper functions.
The short version: **content changes should only ever touch the YAML
file.** A separate YAML file (rather than Typst `#let data = (...)`
dictionaries inline) was chosen so the data file can be edited without
knowing any Typst syntax, and so layout logic stays cleanly separated from
content.

The four layout helpers each correspond to one repeating visual pattern
from the original LaTeX resume, factored out so a layout tweak happens in
exactly one place:

- `section(title, body)` — a big heading with a rule underneath
- `entry(date, body)` — a right-aligned date/label next to a left-aligned
  content block (used almost everywhere)
- `label-grid(rows)` — a flat two-column "label: value" list (Personal
  Data, Trainings, Languages)
- `exptitle(name, date)` — a sub-heading with a thin rule, used only
  inside Work Details

`data.yml` fields are plain text with semantic keys (`birthplace`,
`degree`, `institution`, `company.name`/`url`, etc.) — no Typst markup in
the data. All smallcaps/bold/italic/link formatting is applied in
`resume.typ`, via a `md()` helper (`eval(s, mode: "markup")`). The one
exception: paragraphs inside `work[].entries[].paragraphs` may contain
inline `#link("url")[text]` markup for links mentioned in prose — these
are free-form work-history prose that occasionally names a side
project/product with a link, and extracting every such link into a
structured field wasn't practical. See `docs/schema.md` for the full field
reference.

This plain-text-by-default design was a deliberate reversal from an
earlier version where every field was literal Typst markup (label/value
pairs with hand-written `#link(...)`, inline `#smallcaps[...]`/`*bold*`,
etc.) — that required knowing markup syntax and the `\@`-escaping gotcha
for nearly every field. Semantic keys are self-documenting and let a style
change (e.g. "stop small-caps-ing publication venues") happen in one
template place instead of touching every YAML value.

`work` is a single list covering both the "Work Experience" summary and
the detailed "Work Details" section — each item has summary fields
(`date`, `role`, `company`, `url`, `location`, `tagline`) plus nested
`entries` (dated sub-entries with `paragraphs`). These used to be two
separate top-level lists (`work_experience` / `work_details`) that had to
be kept in sync by hand and had already drifted (e.g. `Myplanet` vs
`Myplanet Internet Solutions`) before being merged into one source of
truth.

- `company` is `{name, short_name}`, not one string — `short_name` is used
  in the "Work Experience" summary line, `name` (fuller/formal) as the
  "Work Details" section header. This split exists because the merge
  above needed one `company` value to serve both a concise summary role
  and a fuller detailed-header role, which used to be two different
  strings. Employers with no shorter form just set both to the same
  string.
- `date` (both the top-level one and `entries[].date`) is a list, not a
  formatted string: `[start, end]` for a range, `[start]` for a single
  point in time (e.g. `["2002"]`), or the key omitted entirely for no date
  at all. `resume.typ`'s `fmtdate()` helper reads the list length to
  decide how to join them into `"<start> - <end>"` — this makes "is this a
  range or a point in time" a property of the data shape, not something
  string-sniffed out of a hand-formatted value. Only `work` dates work
  this way; `education`/`publications`/`trainings` dates are always single
  points in time in this data, so they stay plain strings.

Long prose fields (paragraphs, thesis/publication titles) use YAML folded
block scalars (`>-`) wrapped at ~80 columns for readability — folding has
no effect on the rendered output, it just avoids one very long line per
field.

Page breaks are entirely automatic — there are no manual `#pagebreak()`
calls. Instead, `section()` and `entry()` default to `breakable: false`
(each moves to the next page as a whole unit rather than splitting), with
"Work Details" as the sole exception (`breakable: true`) since it's long
enough that forcing it onto one page would leave large gaps; its entries
still individually control their own breakability. See the "Known
gotchas" section below for the paragraph-splitting subtlety this
required.

## Known gotchas (already solved once — don't re-break these)

- **`@` in Typst markup content still needs care.** Typst's markup mode
  treats an unescaped `@` as the start of a label reference
  (`@some-label`), not literal text. Since most YAML fields are no longer
  run through `eval`, plain values like `email: "ufuk@paralaus.com"` are
  safe as-is. But `resume.typ` itself builds a couple of markup-mode
  strings from data (the Github/Twitter `@handle` labels) — use code-mode
  interpolation like `#("@" + value)` rather than writing `@#value`
  directly in markup, or the `@` gets parsed as a label reference and fails
  with `label ... does not exist`.
- **Use the grid `align:` parameter, not `align()` wrapped around cell
  content.** Wrapping cell content in `align(right, ...)` inside a grid does
  *not* right-align text against the shared column width the way you'd
  expect — it visually looked left-aligned. Passing `align: (right, left)`
  (or similar) directly to `grid()` is what actually works. This is used in
  both `entry()` and `label-grid()`.
- **Right-aligned date/label columns need `justify: false` scoped locally.**
  The document-wide `#set par(justify: true)` (used for body text) makes
  wrapped, right-aligned short labels (e.g. "Oct 2016 - Dec 2018" wrapping
  to two lines) stretch ugly. Fixed by scoping `set par(justify: false)`
  around just those cells, e.g. `{ set par(justify: false); text(...) }`.
- **`parbreak()` alone does NOT stop a paragraph splitting mid-sentence
  across a page break.** Verified directly: a breakable `grid`/`block`
  containing several `parbreak()`-separated paragraphs can still break in
  the middle of any one of them — `parbreak()` only separates paragraphs
  visually, it doesn't make them atomic for pagination. In "Work Details"
  (the one section allowed to break), each paragraph is wrapped in its own
  `block(breakable: false, below: par.spacing, ...)` (read via `context`,
  not hardcoded) so a break can only ever land *between* paragraphs, never
  inside one.
- **Fonts:** `resume.typ` uses the original LaTeX's Fontin fonts
  (`fonts/Fontin-Regular/Bold/Italic.ttf` + `fonts/Fontin-SmallCaps.ttf`,
  committed in this repo). They aren't installed system-wide, so `typst
  compile` needs `--font-path fonts` to find them — see "Build / verify"
  below. Fontin's small caps are a *separate* font file, not an OpenType
  feature of the regular weight, so `resume.typ` has a
  `#show smallcaps: it => text(font: "Fontin SmallCaps", it)` rule to
  switch fonts whenever `smallcaps()` is used — without it, `smallcaps()`
  still runs but silently renders as regular text since Typst can't
  synthesize small caps for this font. If you ever swap fonts again, check
  whether the new font needs the same treatment.

## Build / verify

Use the `typst` CLI (not the Python binding) to compile. `bin/setup`
installs it if missing — Homebrew on macOS; on Linux it uses `gh release
download` (GitHub CLI) to fetch the prebuilt release binary and installs
it into `/usr/local/bin`, since `typst` is **not** in the official
Debian/Ubuntu apt repositories yet (tracking issue:
https://github.com/typst/typst/issues/3679). GitHub Actions runners have
`gh` preinstalled but **not** authenticated by default — the workflow
must set `GH_TOKEN: ${{ github.token }}` in the `bin/setup` step's `env:`,
or `gh` fails with "To use GitHub CLI in a GitHub Actions workflow, set
the GH_TOKEN environment variable" (exit code 4). `bin/build` validates
`data.yml` (via `bin/validate`, see "Schema validation" below) and then
compiles:

```bash
bin/setup   # one-time: installs typst + yajsv if not already present
bin/build   # validates data.yml, then compiles resume.typ -> the PDF
```

`bin/build`'s compile step is equivalent to, and can be replaced by,
running directly from the repo root (`resume.typ`, `data.yml`, and
`fonts/` are all loaded by relative path, so must stay in this layout
relative to each other) — but note this skips the validation step:

```bash
typst compile --font-path fonts resume.typ Ufuk-Kayserilioglu-Resume.pdf
```

`--font-path fonts` is required — the Fontin `.ttf` files live in
`fonts/` but aren't installed system-wide (see the Fontin gotcha above).
Omitting it doesn't error, it silently falls back to a default serif font.

To visually sanity-check changes (Claude Code can't "see" a PDF without
rendering it to an image first):

```bash
pip install pdf2image --break-system-packages   # needs poppler-utils on the system
python3 -c "
from pdf2image import convert_from_path
pages = convert_from_path('Ufuk-Kayserilioglu-Resume.pdf', dpi=80)
for i, p in enumerate(pages):
    p.save(f'page{i+1}.png')
"
```

Then view the PNGs. This was the exact workflow used to catch and fix both
gotchas above — after any nontrivial layout change, render and look before
declaring done.

## Schema validation

`docs/schema.json` is a JSON Schema for `data.yml` (kept in sync with the
human-readable `docs/schema.md` — update both when the shape of `data.yml`
changes). `bin/validate` checks `data.yml` against it using `yajsv`
(installed by `bin/setup`, same `gh release download` approach as typst —
`yajsv` has no package-manager distribution on any platform):

```bash
bin/validate   # checks data.yml against docs/schema.json
```

This is what turns a typo like `date` vs `label` into a clear
`fail: personal_data: birthplace is required` / `Additional property ...
is not allowed` message instead of a raw Typst `dictionary does not
contain key "..."` error at compile time. `bin/build` runs `bin/validate`
itself as its first step — invalid data stops the build before `typst
compile` ever runs, so there's no separate validation step in CI. Run
`bin/validate` on its own if you just want to check `data.yml` without
compiling.

## Things intentionally *not* done yet (possible next steps)

- Only English content — no i18n/localization structure, since that was
  never a requirement.

## Working style notes for future sessions

- This is a personal document with real personal data (address, phone,
  email, DOB). Treat it accordingly — don't publish it anywhere, don't
  include it in commit messages or logs unnecessarily.
- Prefer small, verifiable changes: edit YAML → recompile → render to PNG →
  look → confirm before moving on, especially for anything touching
  `resume.typ` layout logic.
- If asked to add a new job/role, that's almost always a pure YAML edit —
  append one new item to the `work` list — no Typst code changes needed.

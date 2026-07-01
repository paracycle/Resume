# `data.yml` schema reference

This is the human-readable reference; `schema.json` in this directory is
the machine-checkable JSON Schema, enforced by `bin/validate`. Keep both
in sync when the shape of `data.yml` changes.

All fields are plain text — no Typst markup needed or expected. All
smallcaps/bold/italic/link formatting is applied by `resume.typ`, not by the
data file.

**Exception:** paragraphs inside `work[].entries[].paragraphs` may contain
inline Typst markup (currently used only for `#link("url")[label]`, to link
a project/product mentioned in prose). These are rendered through the
`md()` helper in `resume.typ`. Every other field is inserted literally (no
`eval`), so special characters like `@` do not need escaping there.

Long text fields (prose paragraphs, thesis/publication titles) use YAML
folded block scalars (`>-`) wrapped at ~80 columns, so no single line in
the file gets too long to read comfortably. Folding joins the wrapped lines
back into one space-separated string when parsed — it has no effect on the
rendered output, it's purely for editability.

## Top level

| Key | Type | Notes |
|---|---|---|
| `first_name` | string | |
| `last_name` | string | Wrapped in `#smallcaps[]` by the template |
| `personal_data` | dict | See below |
| `work` | list | One item per employer; summary + detailed entries |
| `education` | list | |
| `publications` | list | |
| `trainings` | list | |
| `languages` | list | |
| `interests` | list of strings | Rendered as separate lines |

## `personal_data`

A single dict with semantic keys (not a list of label/value pairs):

```yaml
personal_data:
  birthplace: "Istanbul, Turkey"
  birthdate: "27 July 1975"
  address: "Chrysanthou Mylona 8, Flat 301, 1085, Nicosia, CYPRUS"
  phone: "+357 95969398"
  email: "ufuk@paralaus.com"        # no escaping needed
  github: "paracycle"                # username only, no @ or URL
  twitter: "paracycle"                # username only, no @ or URL
  linkedin: "ufukkayserilioglu"       # profile slug only, no URL
```

The template builds labels ("Place and Date of Birth:", etc.), the
`mailto:`/`github.com/`/`twitter.com/`/`linkedin.com/in/` links, and the `@`
prefixes for Github/Twitter handles.

## `education`

```yaml
- date: "August 2005"
  degree: "MSc and PhD in Physics"      # rendered in smallcaps
  degree2: "..."                         # optional second degree line, smallcaps
  institution: "Bogazici University"     # rendered bold
  location: "Istanbul"
  thesis: "Quantum Group Structures..."  # optional, quoted, prefixed "Thesis:"
  advisor: "Metin Arik"                  # optional, prefixed "Advisor: Prof.", smallcaps
  gpa: "3.63/4.0"                        # optional, prefixed "GPA:", smallcaps label
```

`degree2`, `thesis`, `advisor`, `gpa` are all optional — omit the key
entirely if there's nothing to show for that entry.

## `work`

One item per employer. Each item has a short summary (shown in "Work
Experience") plus one or more dated `entries` (shown, grouped by company,
in "Work Details"). These two views used to be separate top-level lists
(`work_experience` and `work_details`) that had to be kept in sync by hand
— they're now a single source of truth.

```yaml
- date: ["Dec 2018", "Present"]   # summary + Work Details header
  role: "Engineering Manager"      # prepended as "<role> at" (summary)
  company:
    name: "Shopify"          # fuller/formal name — Work Details header
    short_name: "Shopify"    # concise name — Work Experience summary line
  url: "https://shopify.com" # link target (summary + Work Details header)
  location: "Ottawa, Canada" # (summary)
  tagline: "Commerce Platform"   # rendered italic underneath (summary)
  entries:                        # dated sub-entries (Work Details)
    - date: ["Aug 2020", "Present"]
      paragraphs:                # list of strings; markup allowed here
        - "First paragraph of this entry..."
        - 'Second paragraph with a #link("https://example.com")[link].'
```

The "Work Experience" summary line is rendered as: `<role> at
<company.short_name>, <location>` (linked to `url`) then `_<tagline>_` on
the next line. The "Work Details" section renders one header per employer
(`company.name` + `date`) followed by its `entries`.

`company.name` and `company.short_name` can be the same string when there's
no shorter form worth using (see e.g. `Shopify`, `Enkuba`) — the split only
matters when the formal name is long (e.g. `name: "Physics Department,
Bogazici University"` / `short_name: "Bogazici University"`).

### Dates: `[start, end]`

Every date in `work` (top-level `date` and `entries[].date`) is a list,
not a formatted string:

- `[start, end]` → rendered as `"<start> - <end>"` (e.g. a job's tenure).
- `[start]` (one element) → rendered as just `<start>` (a single point in
  time, e.g. `["2002"]`).
- Key omitted entirely → renders as a blank date column. Omit `date` for
  entries with no specific date sub-label (see the Parkyeri / Turk.Net /
  Physics Department entries in the existing data) rather than using an
  empty list or empty string.

This only applies to `work` dates. `education[].date`, `publications[].date`
and `trainings[].date` are single plain strings — they're never ranges in
this data, so making them lists would add nothing but boilerplate.

To add a new job: append a new item to this list.

## `publications`

```yaml
- date: "2005"
  title: "Title of the paper"        # rendered italic
  authors: "Author list"
  venue: "Journal/venue name"        # rendered in smallcaps
```

## `trainings`

Flat date/value list:

```yaml
- date: "Jun 2010"          # right-aligned
  value: "SCRUM training"   # left-aligned
```

## `languages`

```yaml
- name: "Turkish"              # right-aligned; template appends ":"
  proficiency: "Mothertongue"  # left-aligned
```

## `interests`

Flat list of strings, one per line:

```yaml
interests:
  - "Technology, Open-Source, Programming"
  - "Physics, Mathematics"
```

## Adding a brand-new section

If you need a section the template doesn't already support (all current
sections map to one of `section()` + `entry()`/`label-grid()`/`exptitle()`
in `resume.typ`), the pattern is:

1. Add a new top-level key to `data.yml` with whatever plain-text
   shape makes sense (usually a list of dicts with semantic field names).
2. In `resume.typ`, add a `#section("New Section Title")[...]` call with a
   `#for` loop over `data.new_key` inside it, reusing `entry()` or
   `label-grid()` if the shape matches, applying any smallcaps/bold/italic/
   link formatting in the template rather than in the data (see
   `CLAUDE.md` for why), or writing a small amount of new grid/layout code
   if it's a genuinely new visual pattern.

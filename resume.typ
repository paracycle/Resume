// Ufuk Kayserilioglu's Resume — Typst template
//
// This file contains ALL layout/styling/formatting. data.yml holds
// plain-text content only (except work[].entries paragraphs, which may
// embed inline #link(...) markup for links mentioned in prose) — edit that
// file to update the CV, and recompile with `bin/build` (or `typst compile
// --font-path fonts resume.typ Ufuk-Kayserilioglu-Resume.pdf`).

#let data = yaml("data.yml")

// Fontin-*.ttf (in fonts/) must be discoverable by the Typst compiler —
// pass --font-path fonts since they aren't installed system-wide
// (bin/build does this). See CLAUDE.md "Build / verify".
#set page(paper: "a4", margin: (x: 2.2cm, y: 2cm))
#set text(font: "Fontin", size: 10pt, lang: "en")
#set par(justify: true, leading: 0.65em)

// Link colour, matching the original hyperref setup (rgb 0,0.3,0.8)
#let linkcolour = rgb(0, 76, 204)
#show link: it => text(fill: linkcolour, it)

// Fontin's small caps are a distinct font file (Fontin-SmallCaps.ttf), not
// an OpenType feature of the regular weight, so every #smallcaps[...] call
// needs to switch fonts to actually render as small caps (matching the
// original LaTeX's \scshape, which mapped to the same font file).
#show smallcaps: it => text(font: "Fontin SmallCaps", it)

// Renders a string field as Typst markup, so work[].entries paragraphs can
// use things like #link(...)[...]. Plain-text fields don't need this at
// all, but running plain text through it is harmless.
#let md(s) = eval(s, mode: "markup")

// Formats a date field as "<start> - <end>" for a 2-element list, "<start>"
// for a 1-element list, or "" if the field is missing entirely.
#let fmtdate(d) = {
  if d == none or d.len() == 0 { "" }
  else if d.len() == 1 { d.at(0) }
  else { d.at(0) + " - " + d.at(1) }
}

// A full section: heading (small caps, large, ragged, with a rule
// underneath) plus its body content. Unbreakable by default — every
// section except "Work Details" should move to the next page as a whole
// rather than splitting between its entries. "Work Details" passes
// breakable: true since it's long enough that forcing it onto a single
// page would leave large gaps; its entries still individually control
// their own breakability (see entry()).
#let section(title, body, breakable: false) = {
  block(breakable: breakable)[
    #v(0.6em)
    #text(size: 15pt, tracking: 0.5pt, smallcaps(title))
    #v(0.15em)
    #line(length: 100%, stroke: 0.6pt)
    #v(0.3em)
    #body
  ]
}

// A single "date / description" row, used throughout the CV. Unbreakable
// by default — every section except "Work Details" should never have an
// entry split across a page boundary. "Work Details" is the one place
// that needs a page break to be possible *between* the paragraphs of a
// multi-paragraph entry — it passes breakable: true and wraps each
// paragraph in its own `block(breakable: false)` so the break can still
// never land inside a single paragraph.
#let entry(date, body, breakable: false) = {
  block(breakable: breakable, grid(
    columns: (3.6cm, 1fr),
    column-gutter: 0.6em,
    align: (right, left),
    { set par(justify: false); text(weight: "medium", smallcaps(date)) },
    body,
  ))
  v(0.5em)
}

// A company/employer header used inside "Work Details". Kept sticky so
// Typst never breaks the page between the header and whatever follows it
// (otherwise the header can be orphaned alone at the bottom of a page).
#let exptitle(name, date) = {
  v(0.4em)
  block(sticky: true)[
    #smallcaps(text(weight: "medium", name)) #h(0.5em) #text(size: 8.5pt, date)
  ]
  block(sticky: true, line(length: 100%, stroke: 0.4pt))
  v(0.3em)
}

// A flat "label / value" grid, e.g. Personal Data, Trainings, Languages.
// Unbreakable, same as entry() — these lists are always short enough that
// splitting one across a page boundary would only ever look like a bug.
#let label-grid(rows) = {
  block(breakable: false, grid(
    columns: (auto, 1fr),
    column-gutter: 0.6em,
    row-gutter: 0.35em,
    align: (right + horizon, left),
    ..rows.map(row => (
      { set par(justify: false); smallcaps(row.label) },
      row.value,
    )).flatten()
  ))
}

// ------------------------------------------------------------------
// TITLE
// ------------------------------------------------------------------
#align(center)[
  #text(size: 26pt)[#data.first_name #smallcaps[#data.last_name]]
]
#v(0.8em)

// ------------------------------------------------------------------
// PERSONAL DATA
// ------------------------------------------------------------------
#{
  let p = data.personal
  section("Personal Data", label-grid((
    (label: "Place and Date of Birth:", value: p.birthplace + " -- " + p.birthdate),
    (label: "Address:", value: p.address),
    (label: "Phone:", value: p.phone),
    (label: "Email:", value: link("mailto:" + p.email)[#p.email]),
    (label: "Github:", value: link("https://github.com/" + p.github)[#("@" + p.github)]),
    (label: "Twitter:", value: link("https://twitter.com/" + p.twitter)[#("@" + p.twitter)]),
    (label: "Linkedin:", value: link("https://www.linkedin.com/in/" + p.linkedin)[Profile Address]),
  )))
}

// ------------------------------------------------------------------
// WORK EXPERIENCE (summary)
// ------------------------------------------------------------------
#section("Work Experience")[
  #for job in data.work {
    entry(fmtdate(job.at("date", default: none)))[
      #job.role at #link(job.url)[#job.company.short_name], #job.location \
      #emph(job.tagline)
    ]
  }
]

// ------------------------------------------------------------------
// EDUCATION
// ------------------------------------------------------------------
#section("Education")[
  #for edu in data.education {
    entry(edu.date)[
      #smallcaps(edu.degree) \
      #if "degree2" in edu [
        #smallcaps(edu.degree2) \
      ]
      #strong(edu.institution), #edu.location \
      #if "thesis" in edu [
        Thesis: "#edu.thesis" \
      ]
      #if "gpa" in edu [
        #smallcaps("GPA"): #edu.gpa
      ]
      #if "advisor" in edu [
        #text(size: 8.5pt)[Advisor: Prof. #smallcaps(edu.advisor)]
      ]
    ]
  }
]

// ------------------------------------------------------------------
// WORK DETAILS
// ------------------------------------------------------------------
#section("Work Details", breakable: true)[
  #for job in data.work {
    exptitle(job.company.name, fmtdate(job.at("date", default: none)))
    for e in job.entries {
      entry(fmtdate(e.at("date", default: none)), breakable: true)[
        // Each paragraph is its own unbreakable block, so a page break can
        // only ever land between paragraphs, never inside one — plain
        // parbreak() alone does NOT guarantee this (verified: Typst is
        // still free to split a breakable container mid-paragraph). The
        // gap between blocks is read from the live par.spacing setting
        // via context, so it always matches whatever #set par(...) above
        // actually produces, rather than a hardcoded value that could
        // silently drift out of sync.
        #context {
          let gap = par.spacing
          for (i, p) in e.paragraphs.enumerate() {
            let below = if i < e.paragraphs.len() - 1 { gap } else { 0pt }
            block(breakable: false, below: below, md(p))
          }
        }
      ]
    }
  }
]

// ------------------------------------------------------------------
// PUBLICATIONS
// ------------------------------------------------------------------
#section("Publications")[
  #for pub in data.publications {
    entry(pub.date)[
      #emph(pub.title) \
      #pub.authors \
      #smallcaps(pub.venue)
    ]
  }
]

// ------------------------------------------------------------------
// TRAININGS AND CERTIFICATES
// ------------------------------------------------------------------
#section("Trainings and Certificates", label-grid(data.trainings.map(row => (label: row.date, value: row.value))))

// ------------------------------------------------------------------
// LANGUAGES
// ------------------------------------------------------------------
#section("Languages", label-grid(data.languages.map(row => (label: row.name + ":", value: row.proficiency))))

// ------------------------------------------------------------------
// INTERESTS AND ACTIVITIES
// ------------------------------------------------------------------
#section("Interests and Activities")[
  #for (i, line) in data.interests.enumerate() [
    #line
    #if i < data.interests.len() - 1 { linebreak() }
  ]
]

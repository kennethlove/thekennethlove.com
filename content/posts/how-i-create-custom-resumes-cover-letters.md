+++
title = "Custom Resumes and Cover Letters the Easy Way."
date = 2026-10-22
draft = true
tags = [
]
categories = [
    "Blog",
]
summary = "When all you have is a hammer, everything looks like HTML"
+++

## The pitch

My resume is a Hugo page. My cover letter is an HTML fragment. Customizing
either for a specific job never means touching the site's source. Outline of
how the pieces fit:

## 1. The resume is just content

- `content/resume/_index.md` — HTML in Markdown, plain Hugo page.
- Semantic structure: `<section>` per block, `<details>`/`<summary>` per role.
  Collapsed by default on screen, expanded in print. `<time>` elements carry
  machine-readable dates.
- `class="only-print"` hides the real `<h1>`/name on screen (the design uses
  `#`/`##` prefix tricks instead) but prints them.
- HTML comment "slots" mark injection points: `<!-- slot:contact-details -->`,
  `<!-- slot:print-options -->`. No secrets in the repo — the comments are
  inert.

## 2. Private fragments, injected at the edge

- Phone number, email, and the print-options form aren't in this repo at
  all. They live in a private GitHub repo; a Netlify Edge Function fetches
  them per-request and splices them into the slot comments — only when a
  key cookie says it's me.
- Without the cookie, visitors get the lean page; `/cover-letter` without
  it is a 404 like any other 404.
- The whole mechanism — key exchange, slot regex, caching rules, local dev
  loop — is in [Netlify For SSI](/2026/10/netlify-for-ssi/).

## 3. Print styles do the customization

- Radio group (minimal / as-is / full) in the injected form; pure CSS reads
  it: `html:has(#print-full:checked) { details::details-content {
  content-visibility: visible } }`. No JS needed to expand everything.
- `@media print` block: white background, black text, real heading sizes,
  `break-inside: avoid` on details/tables/lists, markers and controls
  hidden.

## 4. One tiny script

- `themes/editor/layouts/resume/list.html` holds ~10 lines of JS: listen for
  changes on the injected `#resume-title` input, set the `<h1>` text *and*
  `document.title`. Empty input falls back to the original title. That's the
  whole script.

## 5. Customizing for a job

- Editing the resume for a posting = edit the Markdown or add a fragment
  slot. Zero rebuild of private data, zero secrets in git.
- Local loop via `just dev`: fragment repo served from disk, `FRAGMENT_URL`
  env override, `just login` grants the cookie, `just test` smoke-checks
  lean vs. injected vs. gated.

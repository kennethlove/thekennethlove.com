+++
title = "Netlify For SSI"
date = 2026-10-22
draft = true
tags = [
]
categories = [
    "Blog",
]
summary = "How to use Netlify's edge functions to inject custom content."
+++

## Server Side Includes, minus the server config

SSI is the old idea: put a marker in your HTML, have the server swap in
private content before the response ships. Netlify's Edge Functions give me
the same trick without touching a web server — the swap happens per-request,
after the static build, at the edge.

Why bother: my resume and cover letter are static Hugo pages anyone can
clone. Phone number, email, and the customization form shouldn't be in the
public repo. So they aren't. They live in a private GitHub repo, and an edge
function splices them in only for me.

## The marker

In my Hugo content, an HTML comment is the slot:

```html
<section id="details-and-controls">
  <dl>
    <dt>Location</dt>
    <dd><b>Portland, Oregon, United States</b></dd>
    <!-- slot:contact-details -->
  </dl>
  <!-- slot:print-options -->
</section>
```

Hugo passes comments through untouched, the static page is safe to publish,
and the build never sees a secret.

## The function

`netlify/edge-functions/private-pages.ts` runs on `/resume` and
`/cover-letter` (wired in `netlify.toml`). The flow:

1. **One-shot key exchange.** Visit `/resume/?key=...` once. The function
   compares against `RESUME_KEY` in near-constant time, sets a 30-day
   httpOnly cookie, and 302s — the key comes off the URL immediately. A
   wrong key behaves *exactly* like no key: no error, no 404 that says "try
   harder." The only observable difference is success.
2. **No cookie, no extras.** Anonymous visitors get the static page, slot
   comments and all — inert and harmless. `/cover-letter` without the cookie
   is a real 404 served from the site's own 404 page, so the route doesn't
   advertise that it exists.
3. **Fetch the fragment.** With the cookie, the function fetches the fragment
   file from the private repo via the GitHub API (`Accept:
   application/vnd.github.raw`). Edge Functions have no filesystem, so
   bundling the fragment wasn't an option — per-request fetch is the design,
   not a compromise. A token scopes read access to that one repo.
4. **Split and splice.** The fragment file is itself a list of slots:

   ```html
   <!-- slot:contact-details -->
   <dt>Phone</dt>
   <dd>+1-...</dd>
   ...
   <!-- slot:print-options -->
   <form id="print-options">...</form>
   ```

   Split it on the slot regex, then `html.replace(SLOT, ...)` over the page.
   One regex, one pass, each named slot filled from the fragment map.
5. **Don't cache the lie.** The merged page no longer matches its ETag or
   Content-Length, so those headers get deleted and the response ships
   `cache-control: private, no-store`. The personalized page can't leak into
   a shared cache or hand a validator that returns different content.

Failure is always "lean page": no token, dead repo, or fetch error all
degraded to exactly what an anonymous visitor sees.

## The payoffs

- **Personalization without a CMS.** The injected form has radio buttons
  (minimal / as-is / full print) and a title input. The print modes are pure
  CSS — `html:has(#print-full:checked)` reveals every `<details>` body in
  `@media print`. The title input is the site's entire JavaScript budget for
  the resume: one `change` listener.
- **A cover letter template with fill-in fields.** `/cover-letter` is a
  frame Hugo publishes with an empty body slot; the letter itself —
  paragraphs with `data-id` hooks — only exists for cookie holders. Same
  mechanism, different fragment URL.
- **Edit without a deploy.** Changing my phone number means committing to the
  private repo, not rebuilding the site. Next request fetches the new
  fragment.

## The local loop

`FRAGMENT_URL` and `COVER_LETTER_URL` are env-overridable, so local dev
never round-trips through GitHub: `just dev` serves the fragment repo from
disk on port 8199 and points `netlify dev` at it. `just login` opens the
key URL to grant the cookie; `just test` curls the lean page, the key
exchange, and the authed page, and checks the markers got replaced.

That last bit matters: the smoke test asserts on *output*, not on the
function's return value — `grep -c 'slot:'` should be zero and the phone
number should be present on the authed fetch, and neither should happen
anonymously.

## Gotchas

- Edge Functions run before CDN caching decisions on matched paths — and
  `onError = "bypass"` keeps a function bug from taking the page down.
- The cookie is `SameSite: Strict` and httpOnly; it never appears in JS.
- Slot comments ship to anonymous visitors. That's fine — they reveal only
  that *something* is injectable, not what.

# private-content

Private half of thekennethlove.com. The site itself (Hugo config, theme,
static, edge functions) lives in thekennethlove.com — not here.

- `cover-letter.html`, `resume-contacts.html` — injected into the gated
  `/cover-letter` and `/resume` pages by that repo's `private-pages` edge
  function, which fetches them from this repo's `trunk` root via the GitHub
  API. Keep both files at the root of `trunk`.
- `content/posts/` — draft posts.

# thekennethlove.com

Source for [thekennethlove.com](https://thekennethlove.com/), the personal site
of Kenneth Love: resume, mentoring, videos, and posts. Built with
[Hugo](https://gohugo.io/), deployed on [Netlify](https://netlify.com).

## Requirements

- Hugo **0.166.0** — pinned in both `netlify.toml` and
  `.devcontainer/devcontainer.json`. If you bump one, bump the other.

Open the repo in a dev container and the pinned Hugo is installed for you;
otherwise install it yourself.

## Local development

```bash
hugo server
```

Preview drafts with `hugo server -D`. Default address is
`http://localhost:1313/`.

## Build and deploy

Netlify builds every push to `main`:

```bash
hugo --gc --minify   # output lands in public/ (gitignored)
```

Deploy settings live in `netlify.toml`. GitHub Pages is disabled; the Google
site-verification file sits in `static/` so it ships with every build.

## Layout

```
archetypes/     front matter template used by `hugo new`
content/        posts/, resume/, mentoring/, videos/
static/         copied verbatim: favicons, webmanifest, verification, images
themes/editor/  the whole theme (vendored, not a submodule)
hugo.toml       site config: menus, taxonomies, permalinks, styles
netlify.toml    build command, publish dir, Hugo version
```

## Writing

New post:

```bash
hugo new content posts/my-cool-post.md   # created with draft = true
```

Front matter is TOML everywhere:

```toml
+++
title = "My Cool Post"
date = 2026-09-23T12:00:00-07:00
draft = true
summary = "One sentence which is shown as the meta description and link preview."
categories = ["Blog"]
tags = ["stuff"]
+++
```

Conventions:

- Posts publish at `/:year/:month/:title/`.
- Include `"Blog"` in `categories` or the post won't show up in the sidebar.
- `summary` feeds `<meta name="description">` and `og:description`; omit it and
  Hugo falls back to the opening text.
- Images go in `static/media/<post-slug>/` and are linked with root-relative
  paths (`/media/<post-slug>/image.png`).
- Code blocks use the `code` shortcode:

  ```
  {{< code file="Dockerfile" lang="dockerfile" >}}
  RUN everything
  {{< /code >}}
  ```

Taxonomies: categories, series, tags.

## Theme

`themes/editor` ("FFEditor") is a vendored MIT-licensed theme inspired by the
Fairy Floss palette. CSS is assembled by Hugo Pipes from
`themes/editor/assets/css/`:

- `colors.css` — palette variables
- `chroma.css` — Rosé Pine Moon syntax highlighting
- `kennethlove.css` — everything else

In production the three are concatenated, minified, and fingerprinted; edit the
sources, never `public/css/`.

## License

Site content: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Theme: MIT.

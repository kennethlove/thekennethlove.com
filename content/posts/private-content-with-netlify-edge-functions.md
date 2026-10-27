+++
title = "A Static Site with Private Content Using Netlify Edge Functions"
date = 2026-10-27
lastmod = 2026-10-28
draft = false
tags = [
  "HTML",
  "Hugo",
  "TypeScript",
  "JavaScript",
  "Netlify"
]
categories = [
    "Blog",
]
summary = "How to use Netlify's edge functions to inject private content."
+++

In my [post about custom resumes], I showed how I used
<abbr title="Cascading Stylesheets">CSS</abbr> and JavaScript to change which
parts of my resume were shown in a PDF and what the resume's title was. I'm sure
you, astute reader, caught that it wasn't a great idea to let the whole world
see all of my contact details or to put whatever name they wanted on my resume
[^1]. But, again, static [Hugo] site on [Netlify]. What can I do?

## Serverless Server-side Includes?

If you're old or curious enough, you might remember when ["server-side includes"],
or <abbr title="Server-side Includes">SSI</abbr> were all the rage.
The general idea is pretty simple. You add a comment to your HTML document,
something like `<!-- include "foo.html" -->` and your server, as the page is
being sent to the client, reads that directive, replaces the comment with
`foo.html`'s content, and continues the response.

Netlify has an [edge functions] feature which allows you to write TypeScript or
JavaScript which can be used to do all kinds of things. Their examples include
things like injecting relevant ads, redirecting visitors, or, what I'm looking
for, serving personalized content. I only want to show the resume customization
options to _me_, not the entire world.

This is where [Mimo], the open Chinese model, and I started brainstorming. I had
three goals, and once I solved one of them, the others should fall into place
quickly.

- Inject private contact details like email addresses and phone numbers
- Inject the resume controls from [before]
- Add a new page for generating cover letters.

They all boil down to the same goal: while serving an HTML page, inject this bit
of custom HTML _only_ if an authorized person is requesting it. Otherwise, give
the plain, static version.

## Preparation H(TML)

The first things I wanted to get together were my HTML fragments. I have three,
one for each of the above bullet points. You've seen this snippet but good things
bear repeating:

```html
<!-- slot:print-options -->
<form id="print-options">
    <fieldset>
        <legend>Print Options</legend>
        <label title="Minimal items">
            <input type="radio" id="print-minimal" name="print-options" value="minimal">
            <span>Minimal</span>
        </label>
        <label title="Opened items">
            <input type="radio" id="print-as-is" name="print-options" value="as-is" checked>
            <span>As-is</span>
        </label>
        <label title="All items">
            <input type="radio" id="print-full" name="print-options" value="full">
            <span>Full</span>
        </label>
    </fieldset>
    <label><input name="resume-title" id="resume-title" placeholder="Resume" type="text"></label>
</form>
```

The `<!-- slot:print-options -->` comment is the marker we'll use later on for
matching snippets to slots. The next snippet I need is the contact details one:

```html
<!-- slot:contact-details -->
<dt>Phone</dt>
<dd>+1-555-555-5555</dd>
<dt>Email</dt>
<dd><a href="mailto:resume@example.com">resume@example.com</a></dd>
```

Again, I marked the snippet with a comment. Nothing really interesting in the
HTML. I realize the anchor isn't really necessary but you never know what might
end up where, so it might as well be useful, right?

Finally, I had the snippet for the cover letter page. It's a longer snippet so I'll
break it up. This is the HTML for the actual letter that gets injected by the
edge function.

```html
<!-- slot:cover-letter -->
<div id="details-and-controls">
    <article>
        <h2 class="no-print">Cover letter</h2>

        <p>Hello <span data-id="hiring-manager">Hiring Manager</span>!</p>

        <p>After seeing your <span data-id="job-title">Job Title</span> opening and reading
        more about <span data-id="company-name">Company</span>, I decided <span data-id="company-name">
        Company</span> was the kind of place I'd like to work at.</p>

        <p data-id="body1"></p>
        <p data-id="body2"></p>
        <p data-id="body3"></p>

        <p>I look forward to talking with you more about <span data-id="job-title">Job Title</span>
        and how <span data-id="company-name">Company</span> and I can work together.</p>

        <p>Thanks!</p>

        <p>Kenneth</p>
    </article>
</div>
```

You can see that this is pretty similar to the resume. Because I had multiple
locations to do substitutions, I used a `data-` attribute. I could have done
this with a `class` attribute but I prefer to reserve those for styling, not
interaction. Each of them marks a bit of text that I'll replace with JavaScript.

After that, I need to update my existing resume file. I removed the `#print-options`
form from the resume page and added two comment markers, `<!-- slot:contact-details -->`
and `<!-- slot:print-options -->` where I wanted those two pieces to show up. I
did the same for the cover letter page, but I also had to add a new Hugo page in
order for it to show up:

```markdown
---
title: Cover letter
---

<!-- slot:cover-letter -->
```

I also had to generate a couple of tokens. First was a fine-grained
<abbr title="Personal Access Token">PAT</abbr> for GitHub. This token was only
allowed to read from the private repository that houses the snippets, nothing
else. I added this to Netlify's environment variables as `SECRET_STUFF_PAT`.
Lastly, I generated a secret key and stored it as the `SECRET_STUFF_KEY` variable.

## Edge(lord) Functions

In order to make sure my HTML comments showed up so Netlify could replace them:
by default, Hugo's minifier would strip them before the edge function would see
them. Adding the following to `hugo.toml` prevents that:

```toml
[minify]
[minify.tdewolff.html]
KeepComments = true
```

You might be wondering if this is a security concern since the comments will be
in the final HTML. Nope. They're just HTML comments. Someone might infer that
they're meant to do _something_ but not what or how.

After that, I had to add a few `edge_functions` entries to my `netlify.toml`:

```toml
[[edge_functions]]
function = "private-pages"
path = "/resume"

[[edge_functions]]
function = "private-pages"
path = "/resume/*"

[[edge_functions]]
function = "private-pages"
path = "/cover-letter-generator"

[[edge_functions]]
function = "private-pages"
path = "/cover-letter-generator/*"
```

These directives tell Netlify to use the `private-pages` edge function whenever
matching paths are requested. Now, with everything in place, it's time to write
the edge function.

Your project will have a `netlify` directory and, inside of there, an
`edge-functions` directory. You'll notice that mine, above, is named
`private-pages` so the file inside of that directory is also named
`private-pages.ts`. `netlify/edge-functions/private-pages.ts` is the final path.

There is a lot in this function so I'll [post it as a gist]. I'll point out the
important bits, though. The first 20ish lines are just setting up URLs, regexes,
a cookie, and a secret key.

When a user, like yourself, visits `/resume/`, there is no cookie set, so nothing
is injected into the response. If, however, you visit
`/resume/?key=<SECRET_STUFF_KEY>` with the right value, the edge function sets a
cookie on your machine that lasts 30 days and answers with a `302` back to the
same path, query string stripped. The redirect gets the secret off your URL as
soon as it has done its job [^2]. The cookie is `httpOnly`, `secure`, and
`SameSite=Strict`. This means scripts on the page can't read it and it never
rides along on a cross-site request. If the cookie exists, the function will then
reach into the correct HTML file, grab the desired snippet, and add it to the HTML.

Finally, the body changed, so validators that no longer describe it, like `ETag`
and `Last-Modified`, get stripped. Otherwise a browser could revalidate against
the unchanged static file and keep showing the private copy from cache after the
cookie expires. `Content-Length` goes because the byte count changed, and
`cache-control: private, no-store` keeps the merged page out of shared and
browser caches. Netlify doesn't cache edge function responses unless you opt in
anyway; these headers are the local half of that.

On anonymous visits, or if something else goes wrong, the standard page is
served so nothing leaks to anyone. So long as you don't know the secret key, you
can't access the special versions of the pages.

## Cover Letter Customization

Now that I have the private pages set up and the injection working, it's time to
handle the cover letter personalizations. This involves an HTML form and a bit
of JavaScript, very similar to what I did with the resume. The form looks like
this:

```html
<form id="print-options" class="no-print">
    <fieldset>
        <legend>Customize</legend>
        <label title="Hiring manager name">
            <input type="text" id="hiring-manager" placeholder="Hiring Manager">
            Hiring manager
        </label>
        <label title="Company name">
            <input id="company-name" placeholder="Company" type="text">
            Company
        </label>
        <label title="Job title">
            <input id="job-title" placeholder="Job Title" type="text">
            Job title
        </label>
        <label title="Body paragraph 1">
            <textarea id="body1" placeholder="Body paragraph 1"></textarea>
            Body paragraph 1
        </label>
        <label title="Body paragraph 2">
            <textarea id="body2" placeholder="Body paragraph 2"></textarea>
            Body paragraph 2
        </label>
        <label title="Body paragraph 3">
            <textarea id="body3" placeholder="Body paragraph 3"></textarea>
            Body paragraph 3
        </label>
    </fieldset>
</form>
```

No radio buttons this time but there are a few text `input` fields and a few
`textarea` fields. If the hiring manager, company name, or job title fields are
left blank, the placeholder values are used. The three `body` paragraphs, however,
are simply left out if blank. Here is the bit of JavaScript I'm using to achieve
that:

```javascript
document.querySelector("#print-options").addEventListener("change", (e) => {
    if (!e.target.id) return;
    document.querySelectorAll(`[data-id="${e.target.id}"]`).forEach((slot) => {
        slot.textContent = e.target.value || slot.dataset.original;
    });
});

// Remember the default text so clearing an input restores it.
document.querySelectorAll("[data-id]").forEach((slot) => {
    slot.dataset.original = slot.textContent.trim();
});
```

In the first chunk, for each field that gets changed, either use the updated
value or the stored original data. The second chunk is what stores that original
data on each field.

Update the fields, print-to-PDF, and now you have a custom cover letter to go
along with your custom resume. Huzzah!

## The Local Loop

You may have noticed in the [gist] that two environment variables are checked
before falling back to the standard GitHub URLs. Those two variables are what
make this possible to do with local development. My `justfile` contains a recipe
for local dev. It uses those two environment variables to fetch the snippets from
a local clone of the private repo being served via Python's `http` module. This
keeps everything local with no trips through GitHub. The recipe also uses
`netlify dev` in order to make the edge functions work locally.

```justfile
# Fragment server port (SurrealDB owns 8123)
frag := "8199"

# Site port netlify dev binds
site := "8888"

# Start the loop: local fragment server + netlify dev (Ctrl-C stops netlify dev)
dev:
    #!/usr/bin/env bash
    set -euo pipefail
    frag="{{ frag }}"
    site="{{ site }}"
    cd "{{ justfile_directory() }}"
    [ -f .env ] || { echo ".env missing — needs SECRET_STUFF_KEY and SECRET_STUFF_PAT"; exit 1; }
    grep -q '^FRAGMENT_URL=' .env || printf '\nFRAGMENT_URL=http://localhost:%s/resume-contacts.html\nCOVER_LETTER_URL=http://localhost:%s/cover-letter.html\n' "$frag" "$frag" >> .env
    [ -d ../private-content ] || { echo "../private-content missing — fragment repo not cloned"; exit 1; }
    if nc -z 127.0.0.1 "$frag" 2>/dev/null; then
        echo "fragment server already on :$frag"
    else
        (cd ../private-content && nohup python3 -m http.server "$frag" > /tmp/fragments.log 2>&1 </dev/null &)
        sleep 1
        nc -z 127.0.0.1 "$frag" 2>/dev/null && echo "fragment server :$frag serving ../private-content"
    fi
    echo "loop: http://localhost:$site/resume/   (grant cookie: just login)"
    if nc -z 127.0.0.1 "$site" 2>/dev/null; then
        echo "netlify dev already on :$site — restart it once if you just added the .env lines"
    else
        echo "starting netlify dev (foreground — Ctrl-C stops it)"
        netlify dev
    fi
```

I also added the following to `netlify.toml` so the local build shows any drafts:

```toml
[dev]
command = "hugo serve --buildDrafts"
```

## Has It Helped?

I've only applied to a few jobs with custom cover letters so far. They don't seem to have done
significantly better than other applications but, honestly, it's too early to tell.
If nothing else, it's another way to keep myself busy, learn something new, and
I can tell y'all about it. That last part is the best one.

[^1]: My name was on there elsewhere but the point still stands.
[^2]: The grant request itself reaches Netlify's edge with the secret still in it, so anything that logs request URLs records it.

[post about custom resumes]: {{< ref "/posts/making-custom-resumes-the-easy-way" >}}
[before]: {{< ref "/posts/making-custom-resumes-the-easy-way" >}}
[Hugo]: <https://gohugo.io>
[Netlify]: <https://netlify.com>
["server-side includes"]: <https://en.wikipedia.org/wiki/Server_Side_Includes>
[edge functions]: <https://docs.netlify.com/build/edge-functions/overview/>
[Mimo]: <https://mimo.mi.com/>
[post it as a gist]: <https://gist.github.com/kennethlove/24333053549f36561551db61be8516eb>
[gist]: <https://gist.github.com/kennethlove/24333053549f36561551db61be8516eb>

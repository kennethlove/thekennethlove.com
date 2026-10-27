+++
categories = [
    "Blog",
]
date = 2026-10-26
draft = false
lastmod = 2026-10-27
summary = "When all you have is HTML, everything looks like a Web page"
tags = [
    "HTML",
    "CSS",
    "JavaScript",
    "Hugo"
]
title = "Making Custom Resumes the Easy Way™"
+++

Well, OK, maybe not the _easy_ easy way but definitely easier than a bunch of
faffing around with a word processor or LaTeX or whatever other solution I
might have seen. Even easier, <abbr title="In My Opinion">IMO</abbr> at least,
than using [LinkedIn] and keeping it actually up-to-date. It has also been one
of those nerdy joys to see if it _could_ be done and then to find out how.

On this site, [/resume/] will show you a static HTML page with my resume on it.
Surprising, I know. My site is generated using [Hugo] so every page, by the time
it gets to you, is just a static HTML document. I don't want to have to run my
own server or anything just to host a rarely-updated blog and a resume, so it's
all hosted on [Netlify].

## Setting up

Seemingly everyone recommends using a customized resume for every job
application. I was laid off recently so I find myself in need of a lot of custom
resumes. At first I thought I'd just let LinkedIn handle the resume but that
generates an awful <abbr title="Portable Document Format">PDF</abbr> and my
design degree just won't let that stand.[^1] My first introduction to the Web
was via plain ol' <abbr title="HyperText Markup Language">HTML</abbr> and <abbr
title="Cascading Stylesheets">CSS</abbr> so they were the first things I reached
for. I knocked up a basic Markdown resume and called it good enough.[^2]

As the hours and days went on, I steadily refined the HTML and CSS until I was
happy with it, I felt it was semantic enough, and the design was readable.
Excellent! Now to just "print to PDF" and...that doesn't look great. Navigation
menus were visible. The document was 4-5 pages long when printed. There had to
be a better way!

## The details

An initial goal was to not involve JavaScript in this any more than necessary;
ideally, not at all. Thankfully, HTML and CSS have come a _very_ long way in
making accessible, designed interfaces easier to build. One of my favorites,
which I used in the resume (you'll see them if you view source), is `<details>`:

```html
<details>
  <summary>Job Title - MM/YY to MM/YY</summary>
  <p>At this job, I did work in exchange for money.</p>
</details>
```

The [`details` element] lets you make content disclosable instead of always
visible. This means you get a marker that, when clicked, opens the element.
In this case, that would show you the paragraph. The `summary` element gives
you a space to explain what's going to be disclosed. I wrapped each of my
positions in a `details` tag and made the employer name the summary. Other
sections also get `details` tags when they make sense.

But here comes the first issue: I want the details to be collapsed when viewed
on the screen (except for the first one), but _open_ when printed, so you can
read the information. You can add an `open` attribute to `<details>` to make it
automatically be open and, if you give 2+ `details` the same `name` attribute,
they'll act like an accordion and only allow one open at a time. Great, but
neither addresses my problem. CSS to the rescue!

I first made sure none of the `details` had matching `name`s. They need to all be
openable. The first one gets the `open` attribute. The screen side is basically
done, but now for the printing. Let's bring some control to this page.

## What you see is what you print

First thing I did was add a print section to my stylesheet with a no-print
rule and a screen section with a print-only rule. If you haven't seen rules
like these before, they look like this:

```css
/* Only applies when printing */
@media print {
  .no-print {
    display: none;
  }
}

/* Hides from screens, shows otherwise */
@media screen {
  .only-print {
    display: none;
  }
}
```

`@media` rules let you target interfaces and apply different rules based on
what that interface needs. The only ones I care about for this article are
these two but there are [other interfaces available].

Next, I had to create the form with the controls. Again, I wanted semantic HTML
so I ended up with something like this:

```html
<div id="print-controls">
  <form>
    <fieldset>
      <legend>Print options</legend>
      <label>
        <input type="radio" name="print-options" id="print-minimal" />
        Minimal
      </label>
      <label>
        <input type="radio" name="print-options" id="print-as-is" checked />
        As-is
      </label>
      <label>
        <input type="radio" name="print-options" id="print-full" /> Full
      </label>
    </fieldset>
  </form>
</div>
```

Since each radio `input` has the same name, only one of them can be selected at
a time; a `select` element would work just as well. Giving each radio button its
own `id` is the important part for what we're going to do next. Now, in my CSS,
I'll add the following kind of rules to my print styles:

```css
html:has(#print-minimal:checked) {
  #experience details:first-of-type::details-content {
    content-visibility: visible !important;
  }
}
html:has(#print-full:checked) {
  details > *:not(summary) {
    display: block;
  }

  details::details-content {
    content-visibility: visible !important;
  }
}
```

The first rule applies to the content (`::details-content`) of the first `details` tag,
making its contents visible, only when that `print-minimal` input has been checked.
Same idea on the second but this time it's watching for `#print-full` to be checked. Since
they are radio inputs and share a `name`, only one can be checked at a time.

The `!important` addition to those two rules is to override whatever the browser is
trying to do with the `details` elements. Marking it as `visible` and giving that
rule the `!important` specificity, means the `details` content is visible.

The input that's checked by default, `print-as-is`, doesn't change any visibility;
whatever is open when you print the page is what gets printed. So now I can customize
which sections of my work history, speaking engagements, and other bits and bobs before
I create the PDF.

## What to title the resume?

I've always believed that you just put your name at the top of the first page of your
resume. Right? Isn't that how it's done? Looking through resources on modern job
applications, I came across the advice to make the headline of your resume the
name of the position. Instead of "Kenneth Love", the first thing on the page should
apparently be "Staff Software Engineer" or whatever. OK, I can do that. I added
another input to my print controls, this time a text input for the resume title.

```html
<input type="text" id="resume-title" />
```

Unfortunately, I can't insert live data via CSS [^3], so we'll have to use some
JavaScript. But not much, so I can convince myself it's okay.

```js
const original = document.title;
document.querySelector("#resume-title").addEventListener("change", (e) => {
  const title = e.target.value;
  if (title !== "") {
    document.querySelector("#title").textContent = document.title = title;
  } else {
    document.querySelector("#title").textContent = document.title = original;
  }
});
```

Can this be better written? Probably. Feel free to submit a PR or message me with
improvements. But it does what I need. When the content of the `input` changes,
the document title, what your browser shows in the tab, and the page's `<h1>`
both get set to that value.

## Print stylesheet advice

I'm not sure how familar most people are with using print stylesheets, so I thought
I might drop a couple of bits of knowledge that I picked up while working on this.

- In your `@media print` block, make sure to set everything to a white background
  and a black foreground. This keeps everything visible when printed on a black &
  white printer or when faxed. Yes, faxes still happen.

  ```css
  * {
    background: white;
    color: black;
  }
  ```

- You can use `break-*` rules to make sure things print together on a page.
  For example, you don't want a job's title and dates on page 1 and the job's
  details on page 2. It's sloppy and hard to read.

  ```css
  details,
  table,
  blockquote,
  ul,
  ol {
    break-inside: avoid;
  }

  h1,
  h2,
  h3,
  h4,
  h5,
  h6 {
    break-after: avoid;
  }
  ```

  The first rule keeps your tables and other groups from being broken apart.
  The second keeps the headline with the thing it's describing.

## Laziness rewarded

Now it's easy for me to update the resume title and what content shows up in the
PDF. This has made it much easier for me to submit applications and I get a
little thrill every time I use it. Giving everyone the ability to rename your
resume might not be the greatest idea, though. I thought of that, too, and I'll
be explaining how soon.

[^1]: Not that what I created isn't a mess, but it's _my_ mess.

[^2]: No, _you're_ too stubborn to listen to the custom resume advice. And who writes cover letters?

[^3]: Am I wrong? Please tell me I'm wrong.

[LinkedIn]: https://linkedin.com/in/thekennethlove
[/resume/]: https://thekennethlove.com/resume/
[hugo]: https://gohugo.io
[Netlify]: https://netlify.com
[other interfaces available]: https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media
[`details` element]: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/details

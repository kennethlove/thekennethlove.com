+++
title = "The Pi-ed Piper"
date = 2026-10-22
lastmod = 2026-10-28
pubdate = 2026-11-13
draft = false
tags = [
  "Pi",
  "AI",
  "Agent",
]
categories = [
    "Blog",
]
summary = "You have entered a realm of pure ~~imagination~~ configuration"
+++

Just like many of you, I've been compelled to use "AI" [^1] for various tasks at
work. It's the currently-inescapable hype train [^2]. At least it's kind of
helpful and interesting once corralled. After many months using different AI
tools, I've settled on the [Mimo] model family and the [Pi] agent harness. I'm
specifically using the [`pi-bolt`] fork of Pi. Let me show you how I'm using
them currently.

## Models

I only really use one subscription model, [Mimo], as mentioned before. Currently
it's on v2.6 and has two variants, "flash" and "pro". By default, every request
and conversation uses the lighter flash variant. For things that benefit from
heavier reasoning, like [Open Design], I use the pro version. If you're
interested in trying Mimo, using [this referral link] will help us both out.

I've had good luck in the past using [Ornith] locally, if you'd like to use a
local model. I haven't used Ornith with Pi specifically [^3] but I don't know of
any reason they shouldn't play nice together.

## What's installed and why

I try to make sure each customization I add to any tool is useful. I don't
always succeed in goal but I think I have, so far, with Pi.

- [`bigpowers`] for brainstorming, planning, and general project organization.
  This is combined with [`pi-beads`] since I use [`beads`] for project
  management.
- [`pi-hermes-memory`], [`billion-context-pi-lean`], and [`pi-declutter`] to let
  me have long-running sessions without them becoming unreadable.
- [`tersio`] gives me [`rtk`], [`caveman`], and [`ponytail`] all at once. Each
  of these helps me to spend fewer tokens. I also combine them with
  [`pi-greybeard`] and [`soft-skills`] to make conversation even more concise.
- [`pi-jj`] and [`pi-jujutsu`] since I use [`jujutsu`] for version control.
  Models already know how to use `git`.
- [`pi-lens`] for code linting, language servers, etc.
- [`pi-ux`], [`keystone`], and [`pi-impeccable`] as design and quality gates.

There are some other packages installed but they're for things like themes and
status lines. If you're interested in them, let me know and I'll happily share.

## Daily use

I always have my token-savers on; caveman, rtk, greybeard, and ponytail. The
last two are interesting in that they reduce cost by reducing the amount of code
that's written or the number of allowed failures. Together they generally result
in the least amount of code that will work. Between terse conversations and
minimal code output, we're already off to a good start.

For anything bigger than a couple of small tasks, I use a planning workflow
that follows a few consistent steps — the same method I used before any of this
and one that works just as well with pen and paper. The workflow itself, and how
I hand it off to agents, lives in [How I Plan Work With
Agents].

## Verdict?

This has, so far, been the most comfortable harness set up I've had yet. In the
past, I've used Claude Code, OpenCode, and [jcode]. They've all been fine and
fairly customizable but they've all felt, somewhat, like working on someone
else's computer. Pi, starting so barebones, has been more comfortable. It has
that vim smell. I'm continuing to tweak my set up, of course, but this one seems
like a winner.

[^1]: C'mon, you and I both know it's just fancy token prediction.
[^2]: And since I'm looking for work, hype trains can be very useful.
[^3]: I used it with [jcode] for a few weeks at my last job.

[How I Plan Work With Agents]: /posts/how-i-plan-work-with-agents

[Mimo]: https://mimo.mi.com/
[Pi]: https://pi.dev
[`pi-bolt`]: https://github.com/opensec-git/Pi-Bolt
[`beads`]: https://beads.gascity.com/
[`jujutsu`]: https://jj-vcs.dev
[this referral link]: https://platform.xiaomimimo.com?ref=ATGSRP
[jcode]: https://jcode.sh
[Ornith]: https://ornith.online/
[Open Design]: https://open-design.ai/
[`bigpowers`]: https://github.com/danielvm-git/bigpowers
[`pi-beads`]: https://pi.dev/packages/@abix5/pi-beads
[`pi-hermes-memory`]: https://pi.dev/packages/pi-hermes-memory
[`billion-context-pi-lean`]: https://github.com/kunkun9527/billion-context-pi-lean
[`pi-declutter`]: https://github.com/ChmaraX/pi-declutter
[`tersio`]: https://pi.dev/packages/@krtclcdy/tersio
[`rtk`]: https://github.com/rtk-ai/rtk
[`caveman`]: https://github.com/JuliusBrussee/caveman
[`ponytail`]: https://github.com/DietrichGebert/ponytail
[`pi-greybeard`]: https://pi.dev/packages/pi-greybeard
[`soft-skills`]: https://pi.dev/packages/soft-skills
[`pi-jj`]: https://pi.dev/packages/@casualjim/pi-jj
[`pi-jujutsu`]: https://pi.dev/packages/pi-jujutsu
[`pi-lens`]: https://pi.dev/packages/pi-lens
[`pi-ux`]: https://pi.dev/packages/@bacnh85/pi-ux
[`keystone`]: https://pi.dev/packages/@getpipher/keystone
[`pi-impeccable`]: https://pi.dev/packages/pi-impeccable

+++
title = "Project Management Lite With AI"
date = 2026-10-22
lastmod = 2026-11-05
pubdate = 2026-11-05
draft = false
tags = [
  "AI",
  "Agent",
  "Planning",
  "Beads",
  "Bigpowers",
  "TODO",
]
categories = [
    "Blog",
]
summary = "Do you have a minute to hear about our lord and savior, `beads`?"
+++

In my experience, sooner or later every project needs some sort of management.
If you're lucky, you can get by with a `TODO.txt` or maybe `TODO:` comments in
your code. If you're really lucky, someone else does the project management. But
what if you need more than a text file but nothing approaching [Jira]? That's
what I've been sorting out for the last year or so.

This acts as an unofficial follow-up to my [How I Plan Work with Agents]. Read
that for _what_ I do instead of _how_ I do.

## The unbearable weight of Jira

If you've never been involved in project management before, it can be _a lot_.
Not only is there, you know, work that needs doing, but now you have to figure
out how to track the work that's waiting or in progress or done or was a dead
end. This snowballs until you're dealing with company and team priorities, team
vacations, some sort of work-tracking board, grooming, sprint planning, and on
and on. If it has a ceremony attached to it, you probably have to do it [^1].

I'm just one person, though, working on a project of my own. One human plus AI
agents just doesn't need a Jira board [^2]. I already showed you
[how I plan work with agents] so this is more of a tool guide than a how-to.
This has been my go-to approach while working with AI agents. So, I'm assuming
you're like me and using agents. You're also tired of trying to keep track of
which agent is doing which task and what still needs doing.

## Let there be lite

In programming, a lot of people follow a rule of proximity: code pieces that
work together should be near each other in the code base. This can't always be
the golden truth, of course, but you do your best. If that's true for a
function, it should also be true for the rest of the project. The `docs/` folder
lives in the repo because it belongs to the project, for example. I'm a firm
believer, too, that everything in your project should be readable by _you_, if
you use agents or not.

I don't want to pay for a service like Jira. I don't want to maintain another
server somewhere to run a self-hosted service. I don't want to use GitHub's or
some other forge service's planning tools. If I do that, now my tasks live on
GitHub and not my local computer. I shouldn't have to have Internet access just
to see what I need to do next. I don't want something that would be hard for
a contributor to use. I want to write code, not sort out ticket tracker issues.

Basically, project management needs to be files that my agents and I can read
and update easily.

## `beads`

Currently, my stack consists of two pieces, all free and open to use. First, we
have [`beads`], which is my issue tracker of choice. It lives on the command
line and your agents can use it easily. There are skills available for most
harnesses and quite a few different
<abbr title="Textual User Interface">TUI</abbr> and
<abbr title="Graphical User Interface">GUI</abbr> applications for human use. As
I mentioned in [my previous post], I usually have an agent break apart my plans
and save them as beads.

Using `beads`, I can prioritize tickets one over the other, I can mark them as
dependent on each other, I can label them by domain, and the app provides a
ready queue of work that's not blocked or claimed. Using these features, agents
can work, often in parallel, without stepping on toes or blocking each other's
work. And with how `beads` syncs via your `git` repository, there's nothing to
keep in sync between users. Do a `git fetch` and you'll have the new beads.

## With `bigpowers` comes big docs directories

Yeah, this one's a little trickier. If you aren't a little careful about it,
this set of skills can swamp you in Markdown and <abbr title="Yet Another Markup
Language">YAML</abbr> files. Most of them are good to have around, though, so I
don't complain much [^3].

Before I start agents on a feature or a fix, I need to understand the work
myself. This is where we get a little closer to project management and not just
keeping track of tickets. [`bigpowers`] gives us a more visible paper trail of
work and planning than `beads` alone, since full documents usually care more
information than a single ticket. That last bit's important: you need to know
**how** and **why** to do something just as much as you need to know **what**
that something is [^4].

`bigpowers` shines, for me at least, in planning. It's a good tool for keeping
scope creep low and for justifying decisions with
<abbr title="Architectural Decision Record">ADRs</abbr>. If you aren't familiar
with ADRs, they're documents used to describe what you need and why, which
options you've tried, and what you've settled on...and why. They often come out
of spike/research tickets but don't have to. `bigpowers` helps you create and
keep specs, plans, and the like up-to-date in Markdown files, an easy format for
humans [^5].

Do `bigpowers` and `beads` overlap? Yes, quite a bit in some ways. They're both
for tracking work. You could get by with just `bigpowers` but I find `beads` to
be more intuitive for how my brain works.

## What about the agents?

You'll need to install a different extension or set of skills for either of
these tools if you want agents to work with them. Since I'm currently using
[Pi], I have the [`pi-beads`] extension installed. If you don't see skills for
your chosen harness or agent, I'm sure your agent could convert existing ones.

## Actually using this

I've been following some variation of this approach for a year or more. It has
been extremely helpful for both work and home projects.

### Good

Since the trackers are machine-readable and -updatable, agents can claim,
update, and close tickets all on their own; I don't have to keep track or
translate anything. But, if something is wrong, I can correct it by either
editing the bead or the related Markdown planning documents. And since agents
only act on _ready_ work, you can concentrate on getting more work ready without
an agent trying to preempt you.

### Bad

But, adopting this approach can have some downsides depending on your
environment. If you're trying to use this for tracking cross-team initiatives,
it's going to be clunky. If you need emails or permissions or, I dunno, Gantt
charts, this isn't the solution you're looking for. Neither of these tools make
it easy for searching across multiple projects although the Markdown files are
extremely searchable. If you're working with a lot of non-technical people, this
might be a more difficult situation since they'll have to read Markdown files or
you'll have to set up some kind of `beads` GUI for them.

These aren't the greatest roadblocks but it's important to know about them. If a
system doesn't work for you, don't use it. Find the tools that make you able to
do the work how _you_ think, not someone else.

### Ugly

It can take a bit of setup, even just for yourself. That's a one-time operation,
though, so I think you'll make it. If you're like me, though, you'll be
tinkering for days.

Once a project's team grows beyond a couple of people and agents, someone is
going to ask you for a dashboard of your progress, audit trails for compliance,
or some other business thing that these tools, especially `beads`, don't make
easily available.

If you find yourself needing project management for 40 people, you're going to
want to find something else. Luckily, that path has been under development for a
long time. You'll find something.

## Verdict?

I plan to stick with this approach, at least for personal projects. I'm sure
I'll evangelize `beads` at future companies, along with other winning tools. If
you try it out, let me know how it goes [^6]!

[^1]: I'm sorry you have to do all of that. I'll stick to code, thank you.
[^2]: How do you hold standup with software anyway?
[^3]: Not too much anyway.
[^4]: **When** is always yesterday, **who** is inevitably you, and **where** is
  none of my business. Work where you're comfortable.
[^5]: I find it's best to not think about the YAML.
[^6]: I never know how to wrap these up.

[how I plan work with agents]: /posts/how-i-plan-work-with-agents
[my previous post]: /posts/how-i-plan-work-with-agents
[`beads`]: https://beads.gascity.com
[`bigpowers`]: https://github.com/danielvm-git/bigpowers
[Pi]: https://pi.dev
[`pi-beads`]: https://pi.dev/packages/@abix5/pi-beads
[Jira]: https://www.atlassian.com/software/jira

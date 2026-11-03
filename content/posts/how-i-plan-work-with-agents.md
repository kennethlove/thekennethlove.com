+++
title = "How I Plan Work With Agents"
date = 2026-10-22
lastmod = 2026-11-03T15:16
draft = false
tags = [
  "AI",
  "Agent",
  "Planning",
]  
categories = [
    "Blog",
]
summary = "A pen-and-paper method, handed to robots"  
+++

Like so many people in the software industry, I've been pushed to use and
experiment with various AI tools over the past few years. Between my years of
actual industry experience writing software and organizing projects and the
last few years trying to get useful code out of AI agents, I've come up with an
approach that consistently gets me good, usable output.

## Break it down

Whether I'm working with AI agents or people, the first thing most tasks require
is to be broken down into their logical, ordered parts. Sometimes this takes
multiple passes, even across multiple days, and that's fine. The important part
is to make sure the work is well defined before you start on it. Honestly, you
can do this all with AI, in a blank text document, or on a piece of paper. Maybe
it's arrogance, maybe it's experience [^1] but it generally tends to work and
work well.

First, decide what you want to create. What is your project idea? Whatever it
is, write it out fairly exhaustively. You want to capture as much of the project
as you can. You can always come back to this description and update and refine
it. This is a spot where I usually ask AI for a quick sanity check: grammar,
spelling, and whether or not the idea is expressed enough to begin work. Be
careful. A lot of AIs will take this as permission to start on the project. It's
not, so stop your bot if it acts up.

Second, you need to break the project down into steps. If you want to follow
common workplace practices, you'd call these *epics*, *stories*, and either
*tasks* or *tickets*. An epic is a big chunk, like "Build user sign up and login
flow". Inside of an epic, you'll have stories, which describe a step in the
process. Maybe epic 1, story 1 (`e1s1`) is to research existing solutions.
Sometimes that's where it ends. Other times, you'll break the story down further
into tasks. A task like `e1s1t1` would be to learn how OAuth works.

None of these things are binding, by the way. You can do as much or as little of
them as you want to. They're mostly here to make sure you don't forget
anything and that your project is thought through. Get in some practice because
we're basically going to repeat this each time we "run out" of work.

## When for the win

Great, you know most of the major points of your project. Now go through that
list of points and decide if it needs to be done *soon*, *later*, or *someday*.
The *soon* items are your proof that your idea warrants further exploration.
This proof might look like research findings, talking to experts, or building an
MVP. The *later* items are often things that can happen in another stage of the
project or items that users, including yourself, won't mind being weird for
awhile. Your *someday* items, if you're anything like me, probably belong in
another project, almost definitely in a different piece of work.

Pick the tasks that need to be done the soonest and start working on them. This
is where I find [a system like `beads`] to be really useful. If your tasks are
connected to other tasks, you can see which tasks rely on which ones. Find one
of these tasks and get started on it.

## Markdrowning

You can do most or all of the above with the assistance of your favorite AI
agent. Using a [skill set like `bigpowers`] almost naturally nets you a system
similar to mine. I usually have `bigpowers` handle creating the epics, stories,
and tasks in `beads` for me. I also let it create the Markdown files it wants to
create as they provide a nice-enough trail for humans to follow without having
to install `beads`. This can be a lot of files, especially if you use it for
brainstorming. Ask it to clean up after itself.

## Release the hounds

Once things are ready to go, specs are nailed down, work has been picked out, I
usually work with a dispatch style approach. I'll have one "main" session
running and from there I'll tell my agent to create subagents to work on tasks.
They're usually good enough to be able to tell where work would overlap or
conflict. If you're going to use concurrent agents, make sure you're using
[`jj` workspaces] [^2]. Keeping the robots out of each other's way is required
for this approach to work smoothly.

The two main agents I use are ["scout"] and ["worker"]. I use the scout to look
for things in my codebase. The worker is the one used for actually implementing
the tasks that have been defined. There are [other agents] in that repo so be
sure to check them out. I have the worker agents follow a <abbr title="Test
Driven Development">TDD</abbr> style workflow so they can prove what they've
done. Agents aren't done until everything comes up green: tests, lints,
formatting, coverage, whatever you want to use as a criterion for done. I also
use tools like this [UX audit] to make sure the work has enough contrast, large
enough fonts, etc.

After that, the agents make a pull request that I review like I would any other
engineer's code. Once the code is up to snuff, I'll merge the PR and start the
whole thing over again. Is it a lot of setup? Sometimes. Does it always produce
good work? No. Does it prevent most AI slop? Yes. Does it keep you aware of the
project? Yes. Overall, I think it's a winning strategy that allows me to work on
multiple projects or multiple tasks at the same time while keeping a strong
sense of control.

[^1]: Maybe it's Maybelline
[^2]: or [`git` worktrees] if you're using `git`, I guess.

[a system like `beads`]: https://beads.gascity.com
[skill set like `bigpowers`]: https://github.com/danielvm-git/bigpowers
[`jj` workspaces]: https://docs.jj-vcs.dev/latest/working-copy/#workspaces
[`git` worktrees]: https://git-scm.com/docs/git-worktree
["scout"]: https://github.com/nicobailon/pi-subagents/blob/main/agents/scout.md
["worker"]: https://github.com/nicobailon/pi-subagents/blob/main/agents/worker.md
[other agents]: https://github.com/nicobailon/pi-subagents/tree/main/agents/
[UX audit]: https://pi.dev/packages/@bacnh85/pi-ux

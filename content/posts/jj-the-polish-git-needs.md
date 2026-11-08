+++
title = "`jj`: The polish `git` Needs"
date = 2026-10-22
pubdate = 2026-11-08
lastmod = 2026-11-08
draft = false
tags = [
  "Jujutsu",
  "jj",
  "git",
  "Version Control",
]
categories = [
    "Blog",
]
summary = "Really, y'all, it's **that** good."
+++

I can remember spending many, many days reading, experimenting, and cursing when
trying to learn how Subversion (SVN) worked back in the early 2000s [^1]. And
then, miracle of miracles, along came a bunch of non-SVN version control systems
(VCS) like [Darcs], [Bazaar], [Mercurial] (hg), and, of course, [Git]. Each of
them had features the others didn't. Some where easier to use, some harder. I
gave each one a try for personal projects and there was, obviously, one clear
winner: Darcs. That wasn't the popular opinion, though, and Git won in the end.
But Git has always needed some polish if you weren't Linus working with a
mailing list for collaboration [^2].

I convinced the developer team at my next job to switch to Git and I haven't had
to use anything else since. And over the intervening 20 years, I've learned to
do everything I need to do in Git. It's a well-known tool by now. But it's a
tool that I'm never sure _isn't_ going to suddenly take off a finger.
`git stash` always felt easy to clutter and overwrite. The one or two times I
had to go into `git reflog` were  more than enough to keep me out of there
unless the situation is _dire_. And, honestly, I always kind of hated rebasing.
Mostly because of the rewriting of history [^3] but also because I was never
sure just where my changes would end up [^4]. Let's be honest, too, do you
_like_ figuring out merge conflicts?

But then, sometime in the last couple of years,  I found [Jujutsu].

## Free trial session

Jujutsu (`jj`) is a new, free, open source VCS that has an almost fluid history
system. Jujutsu brings in a few new features of its own. For starts, the UI and
version control algorithms are abstracted away from the systems used to serve
the content. Eventually this will let it work on top of other backends, like
Mercurial, but for now it lives on top of Git. This is my favorite bit,
honestly, because it means that `jj` projects can live on [GitHub] with no real
problems.

Jujutsu also combines concepts from a few different existing systems. Like `hg`,
`jj` borrowed the revset language for selecting commits. Jujutsu also doesn't
have a dedicated staging area and branches are anonymous. Like Darcs, conflicts
in `jj` are first-class objects. That means conflicts live at the same level as
commits. Git just sees conflicts as textual differences. This difference means
that `jj` can often resolve conflicts automatically. Also like Git, `jj` tries
to be as fast as possible.

The other new features that `jj` brings were a little more mindbending for me
than I expected.

## You must unlearn what you have learned

The first feature that `jj` brings that took me awhile to get used to was the
working-copy-as-commit concept. Your current file state is the current repo
state, kind of like a snapshot. Changes to files get recorded automatically,
just like if you were making normal commits, and then those changes get amended
on every change after that. This completely removes the need for features like
Git's `stash` ability or the staging area.

Since every operation gets recorded (commits, pulls, pushes, etc) you have a log
of what's gone on in the repository. This also gives you `jj undo` which will,
you guessed it, undo the last thing you just did. Yes, even merges.

And, combining these concepts and others, `jj` gives you automatic rebase and
conflict resolution. If you modify a commit, every commit that descends from
that one get automatically rebased on top of your changes. I haven't dived into
it enough but this makes patch-based approaches easier (I hear) but my favorite
part is just...well, all of this feature. If you're used to
`git rebase --update-refs` and `git rerere`, this is them combined and
transparent. It takes a few tries to believe it but it's maybe my favorite
feature of Jujutsu.

## Learning the moves

I highly recommend reading the [official docs], [Steve Klabnik's tutorial],
["jj init"] and ["Demystifying Jujutsu (jj) Workspaces"] guides. Here, however,
are lot of the commands I use day-to-day.

| I want to... | Git | Jujutsu |
| --- | --- | --- |
| start a new repo | `git init` | `jj init` |
| view the log of changes | `git log` | `jj log` |
| fetch remote changes | `git fetch` | `jj git fetch` |
| push changes to remote | `git push` | `jj git push` |
| record changes and reset for new ones | `git commit -m "" | `jj desc -m "" && jj new` |
| update last commit with new changes | `git commit --amend` | `jj squash` |
| add only some changes | `git add -p <file>` | `jj split` |
| add current changes to an ancestor commit | ? | `jj squash -r <rev>` |

Jujutsu has branches but they're more of a Git-friendly concept. `jj` branches
are anonymous by default [^6] like in Mercurial. Because of this, most of the
time, I don't name branches until I need to make a PR to GitHub. This is where
[bookmarks] come into play.

Also like Git, Jujutsu has [workspaces] which let you have different physical
checkouts for different branches in your project. This helps you avoid file read
and write conflicts, version overwrites, and other tasks that are sometimes hard
with version control. I use them constantly and some of that information is in
my [How I Plan Work With Agents] post.

## Sweep the leg, Johnny

It's not all sunshine and roses, of course. If, like me, you've spent decades
using a tool, you're going to have some muscle memory to overcome. Luckily, a
lot of the same, or very similar, commands work in both systems. As most Git
hosting options are, well, Git-oriented, you have to take an extra step with
bookmarks when making branches and pull requests. Because `jj` is newer, there
aren't as many tools out there as there are for Git and other VCS. That said, I
haven't found myself needing tools, the command line is very solid and there are
a few useful addons.

## Verdict?

Git is still the <i>lingua franca</i> for version control. This hasn't been an
issue, though, since Jujutsu still uses Git under the hood. I've used `jj` on
several projects at work with no one the wiser. I use it for most of my current
projects on GitHub (look for the `.jj` directory) [^7].

If you like Git but you'd like a simpler overall system, automatic rebases, and
an end to actual merge conflicts, give [Jujutsu] a try. The [official docs] are
excellent so I highly recommend them along with the resources I linked before:

- ["jj init"]
- [Steve Klabnik's tutorial]
- ["Demystifying Jujutsu (jj) Workspaces"]

[^1]: I'm old, y'all.
[^2]: Or maybe I just don't get how that system works because I got in too late?
[^3]: I'm about to be a hypocrite. You've been warned.
[^4]: I probably should have learned more about `git rebase` but I never ended up having to. Rebases should be local-only and all merges should be squashed [^5].
[^5]: Fight me. Or do, I'm not really about that life.
[^6]: _That_ took some getting used to.
[^7]:  In fact, I'm currently building a project, [jjhub], to act as a
  self-hosted GitHub-like for Jujutsu repos. It still has a long way to go but
  it's been fun to work on.

[How I Plan Work With Agents]: /posts/how-i-plan-work-with-agents
[jjhub]: https://github.com/kennethlove/jjhub
[Jujutsu]: https://jj-vcs.dev
[GitHub]: https://github.com
[Steve Klabnik's tutorial]: https://steveklabnik.github.io/jujutsu-tutorial/
["jj init"]: https://v5.chriskrycho.com/essays/jj-init/
[official docs]: https://docs.jj-vcs.dev/latest/tutorial/
["Demystifying Jujutsu (jj) Workspaces"]: https://www.joshualyman.com/2026/02/demystifying-jujutsu-jj-workspaces/
[workspaces]: https://www.jj-vcs.dev/latest/working-copy/#workspaces
[Darcs]: https://darcs.net/
[Bazaar]: https://people.canonical.com/~mwh/serverguide/build/serverguide/C/bazaar.html.en
[Mercurial]: https://www.mercurial-scm.org/
[Git]: https://git-scm.com/
[bookmarks]: https://docs.jj-vcs.dev/latest/bookmarks/

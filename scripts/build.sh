#!/bin/sh
set -e

# WHY: drafts live in the private kennethlove/private-content repo, mounted from
# .drafts by hugo.toml. Only draft builds fetch it; Hugo skips the mount when
# .drafts is absent, so production needs no clone and never sees draft content.
case " $* " in
*" --buildDrafts "*)
    : "${COVER_REPO_TOKEN:?COVER_REPO_TOKEN required for draft builds}"
    if [ -d .drafts/.git ]; then
        git -C .drafts pull --ff-only
    else
        git clone --depth 1 --branch trunk \
            "https://x-access-token:${COVER_REPO_TOKEN}@github.com/kennethlove/private-content.git" \
            .drafts
    fi
    ;;
esac

hugo --gc --minify "$@"

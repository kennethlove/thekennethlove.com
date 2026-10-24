# Local private-content loop: fragment repo served from disk + netlify dev.
# Override with e.g. `just dev` after editing .env — no GitHub push needed.

# Fragment server port (SurrealDB owns 8123)
frag := "8199"

# Site port netlify dev binds
site := "8888"

# Show recipes
default:
    @just --list

# Start the loop: local fragment server + netlify dev (Ctrl-C stops netlify dev)
dev:
    #!/usr/bin/env bash
    set -euo pipefail
    frag="{{frag}}"
    site="{{site}}"
    cd "{{justfile_directory()}}"
    [ -f .env ] || { echo ".env missing — needs RESUME_KEY and COVER_REPO_TOKEN"; exit 1; }
    grep -q '^FRAGMENT_URL=' .env || printf '\nFRAGMENT_URL=http://localhost:%s/resume-contacts.html\nCOVER_LETTER_URL=http://localhost:%s/cover-letter.html\n' "$frag" "$frag" >> .env
    [ -d ../cover-letter ] || { echo "../cover-letter missing — fragment repo not cloned"; exit 1; }
    if nc -z 127.0.0.1 "$frag" 2>/dev/null; then
        echo "fragment server already on :$frag"
    else
        (cd ../cover-letter && nohup python3 -m http.server "$frag" > /tmp/fragments.log 2>&1 </dev/null &)
        sleep 1
        nc -z 127.0.0.1 "$frag" 2>/dev/null && echo "fragment server :$frag serving ../cover-letter"
    fi
    echo "loop: http://localhost:$site/resume/   (grant cookie: just login)"
    if nc -z 127.0.0.1 "$site" 2>/dev/null; then
        echo "netlify dev already on :$site — restart it once if you just added the .env lines"
    else
        echo "starting netlify dev (foreground — Ctrl-C stops it)"
        netlify dev
    fi

# Grant the resume cookie in your default browser (30-day key cookie)
login:
    @open "http://localhost:{{site}}/resume/?key=$(grep '^RESUME_KEY=' {{justfile_directory()}}/.env | cut -d= -f2-)"

# Smoke the loop: anonymous stays lean, cookie injects, cover letter gated
test:
    #!/usr/bin/env bash
    set -uo pipefail
    cd "{{justfile_directory()}}"
    key=$(grep '^RESUME_KEY=' .env | cut -d= -f2-)
    base="http://localhost:{{site}}"
    rm -f /tmp/loop-jar
    anon=$(curl -s -o /tmp/loop-anon.html -w '%{http_code}' "$base/resume/")
    keycode=$(curl -s -c /tmp/loop-jar -o /dev/null -w '%{http_code}' "$base/resume/?key=$key")
    authed=$(curl -s -b /tmp/loop-jar -o /tmp/loop-authed.html -w '%{http_code}' "$base/resume/")
    cover=$(curl -s -b /tmp/loop-jar -o /dev/null -w '%{http_code}' "$base/cover-letter/")
    coveranon=$(curl -s -o /dev/null -w '%{http_code}' "$base/cover-letter/")
    printf 'anon %s markers=%s phone=%s\n' "$anon" "$(grep -c 'slot:' /tmp/loop-anon.html)" "$(grep -c '1-702' /tmp/loop-anon.html)"
    printf 'key %s · authed %s markers=%s phone=%s form=%s\n' "$keycode" "$authed" "$(grep -c 'slot:' /tmp/loop-authed.html || true)" "$(grep -c '1-702' /tmp/loop-authed.html)" "$(grep -c 'id="*print-options' /tmp/loop-authed.html)"
    printf 'cover %s with cookie · %s anon\n' "$cover" "$coveranon"

# Stop what the loop started: fragment server, netlify dev, its hugo and edge isolate
stop:
    #!/usr/bin/env bash
    lsof -ti tcp:{{frag}} 2>/dev/null | xargs kill 2>/dev/null
    lsof -ti tcp:{{site}} 2>/dev/null | xargs kill 2>/dev/null
    pkill -f 'hugo server' 2>/dev/null
    pkill -f 'edge-functions-serve' 2>/dev/null
    sleep 1
    echo "stopped: frag=$(nc -z 127.0.0.1 {{frag}} 2>/dev/null && echo up || echo down) site=$(nc -z 127.0.0.1 {{site}} 2>/dev/null && echo up || echo down)"

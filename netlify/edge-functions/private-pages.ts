import type { Config, Context } from "@netlify/edge-functions";

// WHY: private fragments never touch disk here — Edge Functions have no
// filesystem and the bundler rejects sibling modules, so the fragment is
// fetched from GitHub per request instead.
// WHY: env-overridable so local edits to the fragment can be tested without
// pushing to GitHub — point these at a local static server in `.env` (gitignored,
// never set on Netlify); unset -> GitHub stays the source in production.
const FRAGMENT_URL =
    Netlify.env.get("FRAGMENT_URL") ??
    "https://api.github.com/repos/kennethlove/cover-letter/contents/resume-contacts.html?ref=trunk";
const COVER_LETTER_URL =
    Netlify.env.get("COVER_LETTER_URL") ??
    "https://api.github.com/repos/kennethlove/cover-letter/contents/cover-letter.html?ref=trunk";

const COVER_LETTER_PATH = /^\/cover-letter(\/|$)/;
const SLOT = /<!--\s*slot:([-\w]+)\s*-->/g;
const HAS_SLOT = /<!--\s*slot:[-\w]+\s*-->/;

const COOKIE = "resume";
const COOKIE_TTL = 60 * 60 * 24 * 30;
const KEY = Netlify.env.get("RESUME_KEY") ?? "";

/** Empty on any failure, so a bad key or dead repo degrades to the lean page. */
async function fragment(url: string): Promise<string> {
    const token = Netlify.env.get("COVER_REPO_TOKEN");
    if (!token) return "";
    const res = await fetch(url, {
        headers: { authorization: `Bearer ${token}`, accept: "application/vnd.github.raw" },
    });
    return res.ok ? await res.text() : "";
}

/** Compare in near-constant time; an unset RESUME_KEY can never match. */
function keyMatches(given: string | null | undefined): boolean {
    if (given == null || KEY.length === 0 || given.length !== KEY.length) return false;
    let diff = 0;
    for (let i = 0; i < given.length; i++) diff |= given.charCodeAt(i) ^ KEY.charCodeAt(i);
    return diff === 0;
}

/** Splits the FRAGMENT on its own slot markers: [pre, name, body, name, body...]. */
function chunks(fragment: string): Map<string, string> {
    const parts = fragment.split(SLOT);
    const out = new Map<string, string>();
    for (let i = 1; i + 1 < parts.length; i += 2) out.set(parts[i], parts[i + 1]);
    return out;
}

function inject(html: string, fragment: string): string {
    const slots = chunks(fragment);
    if (slots.size === 0) return html;
    return html.replace(SLOT, (_m, name: string) => slots.get(name)?.trim() ?? _m);
}

export default async (request: Request, context: Context): Promise<Response> => {
    const url = new URL(request.url);

    // One-shot key exchange: mint the cookie, then take the secret off the URL.
    // WHY: a wrong key must behave exactly like no key — a 404 here would tell
    // any prober the parameter does something. Success (cookie + 302) is the
    // only observable difference.
    if (url.searchParams.has("key") && keyMatches(url.searchParams.get("key"))) {
        context.cookies.set({
            name: COOKIE,
            value: KEY,
            httpOnly: true,
            secure: true,
            sameSite: "Strict",
            path: "/",
            maxAge: COOKIE_TTL,
        });
        return new Response(null, {
            status: 302,
            headers: { location: url.origin + url.pathname },
        });
    }

    const isCoverLetter = COVER_LETTER_PATH.test(url.pathname);
    const authed = keyMatches(context.cookies.get(COOKIE));

    // Hugo publishes the frame for /cover-letter but never its body: without the
    // cookie the only answer is 404.
    // WHY: serve the site's own 404 page — a plain-text "Not found" body would
    // single out this route as guarded (same tell class as the wrong-key 404
    // fixed in #19).
    if (isCoverLetter && !authed) {
        const missing = await context.next(new Request(new URL("/404.html", url)));
        return new Response(missing.body, { status: 404, headers: missing.headers });
    }

    const response = await context.next();

    if (!authed) return response; // no cookie -> lean

    if (response.status !== 200) return response;
    if (!(response.headers.get("content-type") ?? "").includes("text/html")) return response;

    const text = await response.text();
    const headers = new Headers(response.headers);
    const html = HAS_SLOT.test(text)
        ? inject(text, await fragment(isCoverLetter ? COVER_LETTER_URL : FRAGMENT_URL))
        : text;

    if (html === text) {
        return new Response(text, { status: response.status, statusText: response.statusText, headers });
    }

    // Body changed: drop validators that no longer describe it, and keep the
    // merged page out of every shared cache.
    headers.delete("etag");
    headers.delete("last-modified");
    headers.delete("accept-ranges");
    headers.delete("content-length");
    headers.set("cache-control", "private, no-store");

    return new Response(html, { status: response.status, statusText: response.statusText, headers });
};

export const config: Config = {
    path: ["/resume", "/resume/*", "/cover-letter", "/cover-letter/*"],
    onError: "bypass",
};

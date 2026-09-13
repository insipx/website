# insipx-site

Minimal Zola site. About (home) / Links / Resume, GitHub footer.

## Run

    zola serve        # http://127.0.0.1:1111
    zola build        # output in public/

## Before deploying

1. Set `base_url` in `config.toml` to your real domain.
2. Edit content:
   - `content/_index.md` -> About (homepage)
   - `content/links.md` -> Links (Projects / Interesting sections)
   - `content/resume.md` -> Resume

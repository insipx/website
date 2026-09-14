+++
title = "Hello, world"
date = 2026-09-12
+++

First post. Mostly here so there's something to look at while the blog styling
settles — it deliberately uses every element the stylesheet already handles.
test

## A list

- Inline `code` sits on a tinted background.
- Links keep the underline offset from the rest of the site.
- Nested punctuation, em dashes — that sort of thing.

## A code block

```rust
fn main() {
    let target = std::env::var("CARGO_CFG_TARGET_OS");
    match target.as_deref() {
        Ok("macos") => println!("cargo:rustc-link-lib=framework=Security"),
        _ => {}
    }
}
```

That's it. See [the Zola docs](https://www.getzola.org/documentation/) for how
the section and page templates fit together.

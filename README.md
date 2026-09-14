# insipx-site

Minimal Zola site. About (home) / Links / Resume, GitHub footer.

## Run

    zola serve        # http://127.0.0.1:1111
    zola build        # output in public/

## Build the Docker image

    nix build .#image-x86_64
    # or for aarch64
    nix build .#image-aarch64

## build just the server binary

    nix build .#srv

## build just the server binary for musl

    nix build .#srv-musl64
    # or for aarch64 musl
    nix build .#srv-aarch64

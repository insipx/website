+++
title = "Writing a Window Manager in Rust (Ruwm)"
date = 2017-07-23
authors = [ "Andrew Plaza" ]
tags = ["code", "linux"]
categories = ["code"]
+++

So I decided to write a window manager. Also this is my first post, a whole 6
(ish?) months since I actually created this website. My three test posts have
been sitting pretty this entire time. At least the Projects section was updated
semi-regularly.

The one project not in the 'Projects' section, however, is this
[Window Manager](https://github.com/InsidiousMind/Ruwm). A side-gig I've been
tinkering with for the past few weeks. It's a Window Manager written in Rust,
using the [rust xcb library](https://crates.io/crates/xcb) bindings, and a few
other interesting code-bases (like [rustpeg](https://crates.io/crates/peg) and
[xkb](https://crates.io/crates/xkb)).

## What's a Window Manager

If you came to this post and don't know what a window manager is, let me tell
you about my obsession for the last 3 years.

{{ <image path="my_rice.png" alt="desktop" width={800} /> }}

Tinkering is something of a hobby for me, so a good window manager on a good
linux distribution is essential. All a WM does is communicate with X11 through
(usually) the xcb or xlib libraries, and 'manages' your windows. Manage, in this
context at least, means tiling, which is a possible layout of windows. Looking
at the above picture, you may notice that the windows are arranged in a very
specific way. They are in their own boxes, and together they look like tiles.
This is a style of WM's known as 'tiling' and it's done in such a way as to
maximize screen real-estate.

A more traditional 'Desktop Environment' like KDE, Gnome, or even Microsoft
Windows doesn't do this without any additional add-ons. Those environments
prefer a 'floating style' as opposed to the 'tiled' style. This decision was
made probably because it's more natural for an average person to move windows
around, resize them, and generally use their environment with ease. Tiling
Window Managers, on the other hand, are made to be as lightweight and efficient
as possible. Some are made in less than 1000 lines of code, (XMonad, dwm, and
even i3 are quite small programs). They are generally used by people who value
function over ease-of-use. However, this does not mean they can't look amazing
(a look at [unixporn](http://reddit.com/r/unixporn) is proof).

If you ever use a Tiling Window Manager, you will notice that instead of windows
floating around on top of each other, they 'snap' into place, and keep that
screen real-estate for themselves. Any other windows that are opened snap into
their own place, horizontally, vertically, or otherwise. Then, it's up to the
user to arrange them to their liking, usually through keyboard bindings rather
than use of the mouse (keyboard bindings since they are faster).

## Why am I writing my own?

Don't get me wrong, there are tons of great Window Managers and Desktop
environments out there. My current favorite, i3, is amazing for what it does.
Which is why I am modeling much of the functionality of the Window Manager I am
writing against it. I've used dwm, XMonad, AwesomeWM in the past, and they're
all great. Many WM's, however, are missing some core functionality which I think
comes in very useful

### HiDPI Support

In recent years, Desktop Environments like Gnome and KDE have come around to
support more and more screens with HiDPI monitors. This means screens with a
very dense pixel-to-screen-size ratio. My laptop, for instance, has a screen
resolution in the realm of 3200x1920px, with a screen size of 13". That's alot
of DPI! (Density Per Inch). Many window managers like i3, dwm, and XMonad
however, lack support for these HiDPI monitors. The user is forced to spend
hours configuring apps, terminals, and programs to look OK with their computer,
even if the programs themselves already support HiDPI. This is because much of
the environment is managed by X11, and pixel densities/ratios have to be
manually set in order to the program to understand that this screen is a HiDPI
monitor. My goal with Ruwm (A combination of Rust and Window Manager) is to
remove this hastle of setting up an environment for a HiDPI screen.

### Touch Support

Similar to HiDPI support, many window managers lack support for touch screens.
It would be useful to be able to re-arrange the tiles in my WM with
touch-gestures on a laptop touch-screen, instead of entirely relying on the
keyboard. Even if a user uses the keyboard 90% of the time, there are instances
where not having touch-screen support is absolutely annoying. For example,
Laptop-all-in-ones are becoming increasingly popular these days, and when
flipped in 'tablet mode' my laptop essentially becomes unusable. In order to do
anything, I have to finagle my way to the keyboard. Having Gnu+Linux/i3 as my
daily driver, this gets annoying, fast.

### Rust

There aren't many window managers written in Rust, much less written in Rust and
using the xcb library rust bindings. Of course, there's
[Perceptia](https://github.com/perceptia/perceptia) (A Window Manager using
Wayland) and there is [wtftw](https://github.com/Kintaro/wtftw) a Window Manager
using X and the Xlib Rust Bindings. Those are about the most popular Window
Managers written in rust to-date. I think, however, that rust is a great
language to write a window manager for. It's language constructs like matching
and loops make for a great way to handle events, functional iteration constructs
and standard-library data structures like B-Tree's are great for putting windows
in neatly-mapped memory spaces, but most of all, it's a memory-safe language
ripe for writing low-level systems-programs in. In addition to all that, Rusts
library is still quite young, but some codebases are finally maturing. Tokio,
Hyper, serde, among others, mean my Window Manager can accomplish IPC support
quite easily (similar to i3's IPC implementation). So I thought, why not! Let's
do it.

### Why not Wayland?

This is probably the most common question I get asked when I mention I'm writing
a Window Manager for Rust using the xcb library.

"Why are you using X11? That so old."

Sure, it's old, the spec I've been reading through is from 1995, and XKB isn't
much better. But if it's not broke why fix it? Wayland has been around for a few
years now, and other than some wonky (At least when I tried them out)
implementations for Gnome and KDE, I haven't seen any real good use of Wayland
yet. X works perfectly fine, and will for years to come. Plus, this gives me a
great opportunity to learn about Linux and Window Systems before moving on to
wayland, which will make my life easier if I choose to create anything for
Wayland.

### Because I love WM's/Rust and I want to learn more

This one's pretty self explanatory. Much of the reason I'm doing this is to
learn both about Linux, Rust, and programming in general. Already, although my
window manager is still quite early in development, I've learned about
[PEG's](https://en.wikipedia.org/wiki/Parsing_expression_grammar), I've learned
more about how linux handles things internally (evdev, xkb, etc.), I've learned
much more about how Window Managers work. All of this I can already apply to
what I use daily, i3, Linux, and programming. I've also learned much more about
Rust's language constructs and have become more proficient in them; everything
from matching, to Option<>, to enums and structs. This WM is covering more
ground than I would have thought at first!

## Where is it at now?

It's still in very early stages. If you were to somehow install ruwm on your
system and put `exec ruwm` in your .xinitrc, all you would get is a black
screen. If you were too look at the logs, however, you would notice that some
preliminary event handlers are written for mapping windows to your screen, and
knowing what keys you are pressing :-). You would, however, be able to write a
pretty nice
[i3-style configuration file](https://github.com/InsidiousMind/Ruwm/blob/master/src/config_parser/config_grammar.rustpeg)
using the grammar I wrote using rustpeg. Though, you would be disappointed to
know it doesn't actually do anything yet.

## Tomorrow, the day after, and the week after.

I plan to shift my focus from writing a configuration grammar (of which I wanted
to just get bindsym, workspace, and focus done for now) to using the XKB library
and setting up an intuitive way to map keys to actions. After some basics in
that area are done, I will shift gears again and get window mapping working,
focusing on putting the windows in a fast and efficient B-Tree and implementing
a re-parenting window-manager according to spec and in the model of i3.

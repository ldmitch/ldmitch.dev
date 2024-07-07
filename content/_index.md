---
title: "Home"
menu: "main"
weight: 1
---

### About

This is my personal website. It will eventually link to my various self-hosted
services along with blog posts on how I set them up, among other topics. These
posts are mostly for my own reference, so they might not always be fully
up-to-date, but if you notice any issues you can
[message me on Signal](https://signal.me/#eu/D9ahAdeW8Zbb9Nlp_Priz3iuK5Cce0le33frY5Xlt31O0QdNprdF5ZmoxcCf88Ga)
or [create an issue in the GitHub repository](https://github.com/ldmitch/ldmitch.dev/issues/new).

### Design philosophy

> The internet has become a bloated mess. Huge JavaScript libraries, countless
> client-side queries and overly complex frontend frameworks are par for the
> course these days.
>
> --- [Kev Quirk](https://512kb.club/)

I have tried to incorporate some of the guidelines outlined in Dr. Jeff Huang's
[Designed to Last](https://jeffhuang.com/designed_to_last/). This site includes
no JavaScript, nor does it load any third-party resources. I.e., native fonts
are used, hotlinking is not. HTML and CSS are unminimized, allowing you to smash
that ~~like button~~ *view page source* button and inspect the markup.

The only major deviation I have made from Dr. Huang's proposed guidelines is the
suggested use of a single page over several. I have used [Hugo](https://gohugo.io/)
to build the site, which constructs web pages using "templates" that merge with
content written in Markdown format. This allows me to write content more easily,
en lieu of basic HTML pages.

Should Hugo ever be discontinued in the future, the existing deployment would
not be affected, and I can make adjustments- it would be fairly trivial to
recompile all of my templates into full HTML files for each page on the site. I
find this to be an adequately resilient setup, balancing a practical writing
experience with avoiding third-party dependencies as much as possible.

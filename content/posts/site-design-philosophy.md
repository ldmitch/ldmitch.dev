+++
author = "Liam Mitchell"
title = "Site Design Philosophy"
date = 2024-07-09
lastmod = 2024-07-23
description = "My website design philosophy"
draft = false
tags = ["meta", "web"]
+++

*Note that this post does not reflect my views on the web in general, nor do I
believe that all or even most sites should follow this philosophy. The
following few paragraphs are an explanation of how I have designed my own site
to maximize maintainability and usability, while serving its intended purpose as
simply as possible.*

I have tried to incorporate most of the guidelines discussed in Dr. Huang's
[This Page is Designed to Last](https://jeffhuang.com/designed_to_last/),
outlined in the snipped below.

> Let's say some small part of the web starts designing websites to last for
> content that is meant to last. What happens then? Well, people may prefer to
> link to them since they have a promise of working in the future. People more
> generally may be more mindful of making their pages more permanent. And users
> and archivers both save bandwidth when visiting and storing these pages.
>
> --- [Dr. Jeff Huang](https://jeffhuang.com/)

This site includes no JavaScript other than Cloudflare's injected [email address
obfuscation](https://developers.cloudflare.com/waf/tools/scrape-shield/email-address-obfuscation/)
script, nor does it load any additional third-party resources. I.e., native
fonts are used, hot linking is not. JavaScript is not inherently evil, but for a
small personal site focused on text content, I believe it to be a mostly
unnecessary source of increased maintenance overhead. I use WebP images over PNG
format wherever possible to reduce bandwidth consumption. I do minimize CSS
against the suggestion, but this whole site is
[open-sourced](https://github.com/ldmitch/ldmitch.dev), anyway, and I want to
make it as light as possible.

The only other deviation I have made from Dr. Huang's proposed guidelines is the
suggested use of a single page over several. I use [Hugo](https://gohugo.io/) to
build the site, which stitches together web pages using "templates" that merge
with documents written in Markdown format. This allows me to write content more
easily, in lieu of basic HTML pages.

Should Hugo ever be discontinued in the future, the existing deployment would
not be affected; the site is "built to last". If I wanted to make more changes
to the site, it would be fairly trivial to recompile all of my templates into
full HTML files for each page. Or I could just migrate my Markdown files to a
new static site generator. I find this to be an adequately resilient setup,
maintaining a practical writing experience while avoiding third-party
dependencies in my workflow to a reasonable degree.

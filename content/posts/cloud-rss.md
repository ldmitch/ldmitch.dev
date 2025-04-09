+++
author = "Liam Mitchell"
title = "Cloud RSS"
date = 2025-04-08
lastmod = 2025-04-08
description = "Cloud RSS, a web-based RSS reader"
draft = false
tags = ["web", "cloudflare", "services"]
+++

## Cloud RSS demo

To skip my meandering, visit my personal demo instance of Cloud RSS:

https://news.ldmitch.dev

## Contents

- [Motivation](#motivation)
- [Cloud RSS](#cloud-rss)

## Motivation

For the longest time, I had been using mobile app RSS/ATOM readers, namely [Feeder](https://github.com/spacecowboy/Feeder) back when I had an Android device, and [NetNewsWire](https://netnewswire.com/) on iOS. These are both great apps-- open-source, free, have great UIs, and serve their purpose as RSS readers quite well. In fact, if a simple RSS/ATOM reader app is all someone is looking for, they should start with either of those two apps, rather than go through the hassle of using this web-based reader.

However, I personally have a couple issues with applications like these, due to no fault of the developers who have put a lot of time and care into their apps-- they're inherent to the nature of these mobile apps themselves. Namely, the fact that my personal device needs to regularly make dozens of connections, fetching from each individual source.

The first problem with this is that background updates can be unreliable, especially on iOS where background tasks are aggressively limited. This leads to me sitting around, waiting for a refresh when I open the app sometimes, which can be especially slow when behind a VPN, on mobile data, etc. The second problem is privacy. My IP address is shared with each of the feed providers, browsing can be observed by a network admin, and potentially ads or even [trackers](https://en.wikipedia.org/wiki/RSS_tracking) can be downloaded via RSS/ATOM content. Finally, the articles can only be read from my mobile phone itself. If I want to use quickly peek at news from another device, I need to install another app.

## Cloud RSS

So how does Cloud RSS work, and how does it help solve the above issues?

Cloud RSS is made up of two repositories, the [front-end](https://github.com/ldmitch/cloud-rss), which is deployed to Cloudflare Pages, and the [back-end](https://github.com/ldmitch/cloud-rss-worker), which is deployed as a Cloudflare Worker. The front-end is a relatively simple React single-page application, leveraging [Chakra UI](https://chakra-ui.com/) as the component system.

The back-end is a single Cloudflare Worker function written in TypeScript, which runs on a schedule every 30 minutes. When triggered, the function will fetch the latest articles from a list of hard-coded sources, then pass the relevant metadata of these articles to a Cloudflare KV namespace. This metadata allows the front-end to render a grid-view of articles (like a standard RSS reader).

When an individual article is requested by the user, a Cloudflare Pages Function (essentially an integrated Worker) is called, which proxies the request to the source, cleans the article itself, then returns it to the front-end. While this *will* lead to a small delay when opening an article, it means that you always get the latest version, *and* ensures that you are never making a direct connection to the source itself. Why is the latter point important? Your ISP/network admin can't track what articles you're reading in that scenario. All they can see is that you're accessing a Cloud RSS instance. If you self-host Cloud RSS and decide to set up Cloudflare Zero Trust to restrict access to your instance, your browsing is essentially completely private to everyone except Cloudflare (who already have your list of sources, anyway).

## Self-hosting

As mentioned, I have a demo of Cloud RSS available at https://news.ldmitch.dev/. This instance uses my personal list of feeds, which can be found on GitHub, [here](https://github.com/ldmitch/cloud-rss-worker/blob/master/sources.json).

To self-host your own instance, you can go through the READMEs of both repositories, and follow the instructions there:
- Back-end (read this first): https://github.com/ldmitch/cloud-rss-worker/blob/master/README.md
- Front-end: https://github.com/ldmitch/cloud-rss/blob/main/README.md

The instructions aren't terribly comprehensive just yet, but they serve as a good enough starting point for anyone already familiar with Cloudflare Workers. I will gradually try to improve the documentation, though, to make it more accessible.

## License

The entire codebase is [MIT-licensed](https://en.wikipedia.org/wiki/MIT_License), so feel free to do pretty much whatever you like with the code.

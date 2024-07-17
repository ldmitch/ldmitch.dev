+++
author = "Liam Mitchell"
title = "Cloudflare With Vultr"
date = 2024-07-15T19:20:20-07:00
lastmod = 2024-07-15T19:20:20-07:00
description = "How to secure access to a Vultr server with Cloudflare Tunnel"
draft = true
tags = ["vultr", "cloudflare"]
+++

## Motivation

## 1: Buy a domain name with Cloudflare

While it isn't strictly necessary to use Cloudflare as your registrar, it will
simplify the setup process of the server since you can quickly enable security
settings for your domain and setup appropriate DNS records. The instructions
below summarize the official
[Cloudflare documentation](https://developers.cloudflare.com/registrar/get-started/register-domain):

- Go to the [Cloudflare dashboard](https://dash.cloudflare.com/) and either
  create an account or sign-in to your existing one.
- On the left-hand side bar, click the "Domain Registration" dropdown and then
  "Register Domains":
  
  ![Cloudflare dashboard sidebar](cloudflare-dashboard-sidebar.webp)

- Search for the root name you want, like "ldmitch", and optionally add the
  top-level domain like ".dev" that you want to buy.
- Fill in the requested details for your domain. While your real name and
  address are required to register the domain, Cloudflare will redact almost all
  of this information so that your domain name will not be publicly associated
  with your phone number, address, etc.
  - You can read about redaction [here](https://developers.cloudflare.com/registrar/account-options/whois-redaction/),
    and you can see an example of what the publicly available data looks like
    after registration by searching for my domain, [ldmitch.dev](https://ldmitch.dev),
    in [Cloudflare's RDAP portal](https://rdap.cloudflare.com). Notice that even
    after Cloudflare's redaction, my country code, "CA", and province, "BC", are
    still public.

## 2: Configure the new domain's security settings

There are some very simple steps you can take to increase the security of your
domain. From the Cloudflare dashboard, click "Websites" and then select your new
domain: 

![websites section](cloudflare-websites-sidebar.webp) 

Use the side bar on the left hand side of the page to access all of the settings
mentioned below:

![website sidebar](website-sidebar.webp)

I have linked to the relevant Cloudflare documentation page for each setting
listed. Please read the linked page(s) carefully before altering any setting if
you don't know what it does.

- Go to "DNS" > "Settings" and enable [DNSSEC](https://developers.cloudflare.com/dns/dnssec/).
  Follow the prompts and note that it could take some time for changes to
  propogate, but you can move on with the following steps without having to
  stick around and wait.
- Go to "SSL/TLS" > "Overview" and set the
  [encryption mode](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
  to [Full (strict)](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/).
- Go to "SSL/TLS" > "Edge Certificates":
  - Enable [Always Use HTTPS](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/always-use-https/).
  - Set the [Minimum TLS Version](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/minimum-tls/)
    to 1.2 and [Enable TLS 1.3](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/tls-13/).
  - Enable [Automatic HTTPS Rewrites](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/automatic-https-rewrites/).
  - **Make sure to read all linked documentation for HSTS settings:** Change the
    [HTTP Strict Transport Security (HSTS)](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/http-strict-transport-security/)
    settings and toggle all [configuration options](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/http-strict-transport-security/#configuration-settings) on, setting the "Max Age Header" to at least 12 months. If you want to read more
    about HSTS and the `max-age` header, see the
    [MDN docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
    and Google's [HSTS Preload List](https://hstspreload.org).
- Go to "Security" > "Settings" and optionally modify any of the available
  settings as you see fit.

## 3: Rent a VPS from Vultr

It's very straightforward to rent and deploy a VPS on Vultr with the web user
interface. I will summarize the steps but really you can just follow the prompts
and end up with the right product.

- Go to the [Vultr dashboard](https://my.vultr.com) and either create an account
  or sign-in to your existing one.
- Click the big blue "Deploy +" button at the top right of the screen and select
  "Cloud Compute - Shared CPU" (unless you know you need dedicted resources).
- Choose the closest region to you.
- Feel free to select the Linux operating system you are most familiar with, but
  note that Cloudflare Tunnel only natively supports Debian and Windows out of
  Vultr's current options, so if in doubt, just pick Debian 12.
  - [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
    is how we will secure SSH access to the server. Debian and Red Hat are the
    two Linux distributions natively supported, so you can probably also go with
    Ubuntu or Fedora on your VPS instead of Debian without too much trouble, but
    I have only tested Debian myself.


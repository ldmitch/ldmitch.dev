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

## Contents

1. [Buy a domain](#1-buy-a-domain-name-with-cloudflare)
2. [Configure the domain](#2-configure-the-new-domains-security-settings)
3. [Rent a VPS](#3-rent-a-vps-from-vultr)
4. [Install a tunnel](#4-install-cloudflare-tunnel)
5. [Access your VPS from the browser](#5-access-your-vps-from-the-browser)

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
  note that Cloudflare Tunnel only natively supports Debian and Redhat-based
  distributions. You can pick Debian or Ubuntu, or any of the
  RedHat/Fedora-esque distros like Alma or CentOS. I will be using Ubuntu LTS.
  - [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
    is how we will secure SSH access to the server later.
- For the hardware plan (CPU, RAM, etc.), you can be conservative with what you
  pick at first. With Vultr, it's easy to upgrade to a more powerful VPS but you
  can't downgrade (yet). You should look up the hardware requirements of the
  services you're interested in hosting to decide. For instance, Matrix
  recommends at least 1 GB of RAM if you plan on joining large, federated rooms
  on a self-hosted Synapse server.
- For "Additional Features", make sure "IPv6" is selected, and then choose
  anything else you're interested in.
- Pick any server hostname and click "Deploy Now". Wait for the installation to
  complete and then we're good to go.

## 4: Install Cloudflare Tunnel

This next part is how we'll stop anyone from connecting to the server over SSH
except users you explicitly allow via
[Cloudflare Zero Trust](https://developers.cloudflare.com/cloudflare-one/). I'll
be summarizing the [official docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/#connect-to-ssh-server-with-cloudflared-access)
once again.

- Open the [Cloudflare dashboard](https://dash.cloudflare.com) and select "Zero
  Trust" from the sidebar.

  ![zero trust](zero-trust.webp)

  - If this is your first time opening Zero Trust, you might get a prompt asking
    you to choose your Cloudflare account and whatnot. Just follow the prompts.
- You will get a brand new sidebar on your screen! Pick "Networks" and then
  "Tunnels".

  ![networks-tunnels](networks-tunnels.webp)

- Click "Create a tunnel" and then pick the "Cloudflare***d***" option. You can
  choose whatever name you like, but picking the same name as your Vultr VPS may
  simplify things.
- You will now be prompted to "Install and run a connector". To do this, we are
  going to connect to the VPS via SSH:
  - From the [Vultr dashboard](https://my.vultr.com), click on your VPS. In the
    overview, you should see a few fields, namely an IP address, username, and
    password:

    ![Vultr-server-overview](server-overview.webp)

  - Open up a terminal or PowerShell window, then type
    `ssh <username>@<IP address>`, replacing the values with the ones listed
    for your VPS.
  - Follow the prompts shown in your terminal, and paste the password when
    asked. If things went smoothly, you should see `<username>@<VPS name>:~#` in
    your terminal. You can enter the `w` command to double check that you are
    logged in, as well as from what IP address you're connecting from:

    ![w-command](w.webp)

    - I already have a tunnel setup on this server, so my client IP address (the
      "FROM" column) isn't shown here, but yours should be.
    - Returning now to "Install and run connectors" page of the tunnel
      configuration, choose either Debian or RedHat depending on what your VPS
      OS is based on.
    - Select "64-bit" as your architecture, then copy the command labeled for
      "If you don't have cloudflared installed on your machine".
    - Paste the copied command into your terminal with the active SSH
      connection, and wait for it to finish.
    - Return to the tunnel page in your browser, and you should see a new entry
      under "Connectors", meaning that your VPS was connected successfully.
    - Click "Next", and then fill out the fields like I have below, choosing
      your domain name from the dropdown menu:

      ![route-tunnel](route-tunnel.webp)

    - Once the fields are filled out correctly, you can save the tunnel.

## 5: Access your VPS from the browser

Next up, we are going to add a self-hosted application to Cloudflare Zero Trust
so that we can enable browser rendering of an SSH terminal, allowing you to
securely access your VPS from any devices. I am summarizing the official docs on
[adding a self-hosted application](https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/self-hosted-apps/)
and [enabling browser rendering](https://developers.cloudflare.com/cloudflare-one/applications/non-http/#enable-browser-rendering).

- From the sidebar, pick "Access" then "Applications":

  ![access-applications](access-applications.webp)

- Click "Add an application" and pick the "Self-hosted" type.
- Enter a name like "vultr-ssh", and set the session duration to something
  convenient but secure for your devices. This is how long the browser will
  remember you after you authenticate, so obviously pick a very low value if
  you use shared devices.
- Pick the same subdomain-domain combination that you used for your tunnel,
  which is probably something like `ssh.yourdomain.abc`
- Scroll down to "Identity providers" and set the parameters like so:

  ![identity-providers](identity-providers.webp)

  - The above settings setup your authentication page so that you will be
    prompted to enter an email address, and if that email is on the allowlist,
    it will be sent a one-time code that you can paste into your browser and
    authenticate yourself.
- Click "Next", then enter a policy name like "allowed-email-addresses".
- Scroll down to "Configure rules" and pick the "Emails" selector, adding your
  email address to the value:

  ![policy-rules](policy-rules.webp)

- Click "Next" and scroll down to the bottom of the page.
- Enable browser rendering for SSH:

  ![enable-browser-rendering](enable-browser-rendering.webp)
- Click "Add application".
- Now to test:
  - Open your subdomain in a new browser tab, `ssh.yourdomain.abc`
  - You should see a prompt asking for your email address like the one below.
    Enter the address your added to the policy earlier:

    ![email-prompt](email-prompt.webp)

  - Check your inbox and either click the link that Cloudflare sent you or copy
    and paste the six-digit code they sent.
  - You will see a new prompt asking for a user. Enter "root" (this is the auto
    generated user that Vultr set up for your VPS):

    ![user-prompt](user-prompt.webp)

  - You will then need to enter the same password you used earlier when
    connecting by SSH from your own terminal/PowerShell window. This can be
    found by going to the [Vultr dashboard](https://my.vultr.com) and clicking
    on your VPS, if you forgot:

    ![Vultr-server-overview](server-overview.webp)

  - You should now be connected to your VPS via SSH in the browser:

    ![browser-rendered-terminal](browser-rendered-terminal.webp)

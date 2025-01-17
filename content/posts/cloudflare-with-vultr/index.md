+++
author = "Liam Mitchell"
title = "Cloudflare With Vultr"
date = 2024-08-04
lastmod = 2024-08-04
description = "How to secure access to a Vultr server with Cloudflare Tunnel"
draft = false
tags = ["vultr", "cloudflare"]
+++

## Motivation

There are plenty of tutorials online on how to setup a virtual private server,
many of them using Vultr as the hosting provider. However, being new to web
hosting, I was worried about the security of my server and how I should go about
locking it down so that no one else could access it. 

I did some research on the topic and decided on using Cloudflare Zero Trust to
control access to my Vultr VPS. The end result requires very little compromise
from my end and I can still manage and maintain services without any extra
overhead, but all incoming connections to the server are blocked. Authentication
is handled by Cloudflare, who in my opinion are a reputable security company, so
that I don't have to spend any time beyond the initial setup worrying about
someone hijacking my hosted services.

The reason for writing this post is to summarize the steps I took so that I or
anyone else can quickly mimic my setup in the future without having to piece
together the various pages of documentation again to get to the same end result.
I have linked to the official documentation from Cloudflare and Vultr where
possible so that you can easily find clarification on any of the steps listed,
and so that if you want to adjust the configurations I use, you'll have the
proper starting place from which to do so.

## Contents

1. [Buy a domain](#1-buy-a-domain-name-with-cloudflare)
2. [Configure the domain](#2-configure-the-new-domains-security-settings)
3. [Rent a VPS](#3-rent-a-vps-from-vultr)
4. [Install a tunnel](#4-install-cloudflare-tunnel)
5. [Access your VPS from the browser](#5-access-your-vps-from-the-browser)
6. [Set the Vultr firewall](#6-set-the-vultr-firewall)
7. [Conclusion](#conclusion)

## 1: Buy a domain name with Cloudflare

While it isn't strictly necessary to use Cloudflare as your registrar, it will
simplify the setup process of the server since you can quickly enable security
settings for your domain and set up appropriate DNS records. The instructions
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
  - You can read about the redaction [here](https://developers.cloudflare.com/registrar/account-options/whois-redaction/),
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
you don't already know what it does.

- Go to "DNS" > "Settings" and enable [DNSSEC](https://developers.cloudflare.com/dns/dnssec/).
  Follow the prompts and note that it could take some time for the change to
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
  note that Cloudflare tunnels only natively support Debian and Redhat-based
  distributions. You can pick Debian or Ubuntu, or any of the
  RedHat/Fedora-esque distros including Alma and CentOS. I'll be going with
  Ubuntu LTS.
  - [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
    is how we will secure SSH access to the server later, but you don't need to
    worry about it just yet.
- For the hardware plan (CPU, RAM, etc.), you can be conservative with what you
  pick at first. With Vultr, it's easy to upgrade to a more powerful VPS but you
  can't downgrade (yet). You should look up the hardware requirements of the
  services you're interested in hosting to decide.
  - For instance, while Matrix Synapse/Element <cite>don't currently publish
    hardware requirements[^1]</cite>, most online resources recommend at least 1
    GB of RAM and plenty of storage space for messages/media. Since I want to
    run my own Synapse server, I configured my VPS with 2 GB of RAM and a 50 GB
    NVMe.
- For "Additional Features", make sure "IPv6" is selected, and then choose
  anything else you're interested in.
- Pick any server hostname and click "Deploy Now". Wait for the installation to
  complete and then we're good to go.

[^1]: See Synapse [issue 6367](https://github.com/element-hq/synapse/issues/6367)

## 4: Install Cloudflare Tunnel

This next part is how we'll permit users you explicitly allow via
[Cloudflare Zero Trust](https://developers.cloudflare.com/cloudflare-one/) to
access your VPS. I'll be summarizing the [official docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/#connect-to-ssh-server-with-cloudflared-access)
once again.

- Open the [Cloudflare dashboard](https://dash.cloudflare.com) and select "Zero
  Trust" from the sidebar.

  ![zero trust](zero-trust.webp)

  - If this is your first time opening Zero Trust, you might get a prompt asking
    you to choose your Cloudflare account and whatnot. Just follow the prompts.
- You'll get a brand new sidebar on your screen, so pick "Networks" and then
  "Tunnels".

  ![networks-tunnels](networks-tunnels.webp)

- Click "Create a tunnel" and then pick the "Cloudflare***d***" option. You can
  choose whatever name you like, but picking the same name as your Vultr VPS may
  simplify things.
- You'll now be prompted to "Install and run a connector". To do this, we are
  going to connect to the VPS via SSH:
  - From the [Vultr dashboard](https://my.vultr.com), click on your VPS. In the
    overview, you should see a few fields, namely an IP address, username (which
    should be "root"), and password:

    ![Vultr-server-overview](server-overview.webp)

  - Open up a terminal or PowerShell window, then type
    `ssh root@<IP address>`, replacing `<IP address>` with the one listed for
    your VPS.
  - Follow the prompts shown in your terminal, and paste the password when
    asked. If things went smoothly, you should see `root@<VPS name>:~#` in your
    terminal. You can enter the `w` command to double check that you are logged
    in, as well as from what IP address you're connecting from:

    ![w-command](w.webp)

    - I already have a tunnel setup on this server, so my client IP address (the
      "FROM" column) isn't shown here, but yours should be.
- Returning now to the "Install and run connectors" page of the tunnel 
  configuration in Cloudflare, choose either Debian or RedHat depending on what
  your VPS operating system is based on.
- Select "64-bit" as your architecture, then copy the command under the label:
  "If you don't have cloudflared installed on your machine".
- Paste the copied command into your terminal with the active SSH connection,
  and wait for it to finish.
- Return to the tunnel page in your browser, and you should see a new entry
  under "Connectors", meaning that your VPS was connected successfully.
- Click "Next", and then fill out the fields like I have below, choosing your
  domain name from the dropdown menu:

  ![route-tunnel](route-tunnel.webp)

- Once the fields are filled out correctly, you can save the tunnel.

## 5: Access your VPS from the browser

Next up, we are going to add a self-hosted application to Cloudflare Zero Trust
so that we can enable browser rendering of an SSH terminal, allowing you to
securely access your VPS from any device. I am summarizing the official docs on
[adding a self-hosted application](https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/self-hosted-apps/)
and [enabling browser rendering](https://developers.cloudflare.com/cloudflare-one/applications/non-http/#enable-browser-rendering).

- From the sidebar, pick "Access" then "Applications":

  ![access-applications](access-applications.webp)

- Click "Add an application" and pick the "Self-hosted" type.
- Enter a name like "vultr-ssh", and set the session duration to something
  convenient but secure for your devices.
  - This is how long the browser will remember you after you authenticate, so
    obviously pick a very low value if you use shared devices.
- Pick the same subdomain-domain combination that you used for your tunnel,
  which is probably something like `ssh.yourdomain.abc`
- Scroll down to "Identity providers" and set the parameters like so:

  ![identity-providers](identity-providers.webp)

  - The above settings set up your authentication page so that you will be
    prompted to enter an email address, and if that email is on the allowlist,
    it will be sent a one-time code that you can paste into your browser and
    authenticate yourself.
- Click "Next", then enter a policy name like "allowed-email-addresses".
- Scroll down to "Configure rules" and pick the "Emails" selector, adding your
  email address to the value:

  ![policy-rules](policy-rules.webp)

- Click "Next" and scroll down to the bottom of the page. Enable browser
  rendering for SSH:

  ![enable-browser-rendering](enable-browser-rendering.webp)

- Click "Add application".
- Now to test:
  - Open your subdomain in a new browser tab, `ssh.yourdomain.abc`
  - You should see a prompt asking for your email address like the one below.
    Enter the address that you added to the policy earlier:

    ![email-prompt](email-prompt.webp)

  - Check your inbox and either click the link that Cloudflare sent you or copy
    and paste the six-digit code.
  - You'll see a new prompt asking for a user. Enter "root" (this is the auto
    generated user that Vultr set up for your VPS):

    ![user-prompt](user-prompt.webp)
    - Notice for Apple device owners: **the browser rendered terminal will not
      work with lockdown mode enabled**, so just whitelist the site in Safari
      and you will avoid the thirty minutes of troubleshooting I went through.
  - You'll then need to enter the same password you used earlier when
    connecting by SSH from your own terminal/PowerShell window. This can be
    found by going to the [Vultr dashboard](https://my.vultr.com) and clicking
    on your VPS, if you forgot:

    ![Vultr-server-overview](server-overview.webp)

  - You should now be connected to your VPS via SSH in the browser:

    ![browser-rendered-terminal](browser-rendered-terminal.webp)

## 6: Set the Vultr firewall

The last thing on the agenda is to restrict all incoming connections to the VPS,
so that connecting through the Cloudflare tunnel is the only way to access the
server. The nice thing about Vultr's firewall interface is that it can be
managed through the web portal, unlike an OS-level firewall like UFW where if
you mess up your rules, you could get locked out. Regardless, we can actually
block *all* incoming connections, since Cloudflare tunnels create outbound
connections to Cloudflare's network as explained [here](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/#how-it-works).

The below instructions are a summary of [these ones from Vultr](https://docs.vultr.com/use-cloudflare-and-vultr-firewall-to-protect-a-vultr-cloud-server#configure-the-vultr-firewall):

- Click [this link](https://my.vultr.com/firewall/) to open the Vultr Firewall
  page.
- Click "+ Add Firewall Group" from the top right of the page.
- Add any rule, like the one I have set up below, to both the IPv4 *and* IPv6
  rule sets by clicking the "+" icon on the far right side (you can remove this
  rule in a second, so it doesn't really matter what you put):

  ![vultr-firewall-default-rules](vultr-firewall-default-rules.webp)
- After adding a rule, you will see a trash icon to delete it, as well as a
  second "drop" rule that was added automatically. You can click the trash icon
  to delete the rule you added, leaving only the drop-any rule which will block
  all incoming connections to your server:

  ![vultr-activated-firewall](vultr-activated-firewall.webp)
  - Again, make sure to perform the above step for ***both the IPv4 rules and
    for IPv6***.
- Once your drop rules are set up, you can attach the firewall to your VPS.
  Return to the ["Compute" page](https://my.vultr.com/), click on your VPS then
  click "Settings" and choose "Firewall" from the sidebar:

  ![vultr-vps-firewall-settings](vultr-vps-firewall-settings.webp)
- From the dropdown menu, select your firewall group (it will probably show up
  as a long string of numbers and letters, unless you also set a description for
  it), and click "Update Firewall Group".
  - Vultr will notify you that it can take up to 120 seconds for firewall rules
    to propagate, so try to wait that long before moving on to the test step
    below.
- Once the firewall has been added to your VPS, you can test whether incoming
  connections are properly blocked by trying to access the server via SSH like
  you did earlier. For a refresher, return to [part 4](#4-install-cloudflare-tunnel)
  and start from the bullet point listed as:

  `You'll now be prompted to "Install and run a connector". To do this, we are
  going to connect to the VPS via SSH`
  - If the firewall is set up correctly, when you run the `ssh` command from
    your terminal like before, the terminal window should "hang" (i.e., freeze)
    for about a minute, before finally giving you a message like:

    `ssh: connect to host <VPS IP address> port 22: Operation timed out`
- Access through Cloudflare tunnel should still work fine. You can verify this
  by navigating to the domain you configured in Cloudflare for your
  browser-rendered terminal (e.g., `ssh.yourdomain.abc`), and attempting to
  login with username "root" and the VPS password.
  - You don't actually need to login. So long as the interface still asks you
    for a username and password, the tunnel is up and running and the VPS can be
    accessed remotely.

## Conclusion

That's it. You should now have a virtual private server hosted on Vultr that can
only be managed by any users you have explicitly allowed through Cloudflare Zero
Trust. You can use this VPS to host whatever services you want, and in order to
access them over the internet, just return to the Vultr Firewall you set up and
add a rule allowing access to the server over that port.

For instance, if you wanted to run a web server, you would probably open ports
80 and 443 to the internet. If you decided to use Cloudflare as your reverse
proxy to the server, Vultr makes it easy to restrict access to a certain port
by setting the "Source" for your rule to "Cloudflare". You can take advantage of
Cloudflare's free DDoS protection and security settings and ensure that any
traffic trying to bypass the proxy is blocked.

---
layout: post
title: HackTheBox - Easy Phish
---

> Customers of secure-startup.com have been recieving some very convincing phishing emails, can you figure out why?

---

This challenge requires an understanding of (or a willingness to Google) a couple phishing prevention mechanisms. 

### SPF
If the Sender Policy Framework (SPF) TXT file is not configured correctly in your domain's DNS table, other servers could send emails on behalf of your domain. In a better configuration, when the secure-startup.com server recieves an email from a different server that is using their domain, the recipient server will check the sending server's authority to use said domain and reject the email if they are not allowed ([RFC 4408](https://datatracker.ietf.org/doc/rfc4408/)).

Let's use the DNS lookup utility ```host``` to find the SPF record and coincidentally the first part of the flag.

![flag1](/images/htb/easyphish/1.png)

### DMARC

> Domain-based Message Authentication, Reporting & Conformance, or DMARC, is a protocol that uses Sender Policy Framework, (SPF)  and DomainKeys identified mail (DKIM) to determine the authenticity of an email message. 
>
> DMARC makes it easier for Internet Service Providers (ISPs) to prevent malicious email practices, such as domain spoofing in order to phish for recipients’ personal information. 
> 
> Essentially, it allows email senders to specify how to handle emails that were not authenticated using SPF or DKIM. Senders can opt to send those emails to the junk folder or have them blocked them all together. By doing so, ISPs can better identify spammers and prevent malicious email from invading consumer inboxes while minimizing false positives and providing better authentication reporting for greater transparency in the marketplace. ([SendGrid](https://sendgrid.com/blog/what-is-dmarc/))

![flag2](/images/htb/easyphish/2.png)

### Solution
We now have the full flag!
HTB{RIP_SPF_Always_{censored}_2_DMARC}
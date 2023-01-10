---
layout: post
title: Configuring Gmail with a Google Domain using Google DNS
---

## Enable email forwarding in the Email section of your Domain settings
1. Go to: `https://domains.google.com/registrar/<your_domain>/email`
2. Click **Add email alias**
3. Set **Alias email** to `*` if you want all emails sent to any address at your domain forwarded to the same email, otherwise specify the specific alias
4. Set **Existing recipient email** to the Gmail address of the account you want to be emailing from

## Add an App Password in your Google Account
1. Open [App Passwords](https://myaccount.google.com/apppasswords)
2. Set **Select App** to `Other (Custom Name)`
3. Name the app whatever you wish, e.g. `<your_domain> Email`
4. Click **Generate** and save the password displayed for the next section

## Add desired address(es) to Gmail
1.  Open [Gmail Accounts and Import Settings](https://mail.google.com/mail/u/0/#settings/accounts)
2.  In the "Send mail as" section, click **Add another email address**.
3.  Enter your name and the address you want to send from.
	* Since **Alias email** was set to `*`, you can specify `<anything>@<your_domain>`. For each mailbox that you want to add (such as those specified in [RFC 2142](https://www.ietf.org/rfc/rfc2142.txt)), you will need to repeat the **Add another email address** process.
	* Keep **Treat as an alias** checked, as there is no other mail system that you can access emails to your domain. To verify your use case, see: [Should I uncheck "Treat as an alias" in Gmail?](https://support.google.com/a/answer/1710338?ctx=gmail&hl=en&authuser=0&visit_id=638089119662480343-748861876&rd=1).
4. Click **Next Step**
5. Set **SMTP Server** to `smtp.gmail.com`, leaving **Port** set to 587
6. Set **Username** to your Google ID, i.e. the `<id>` portion of `<id>@gmail.com`
7. Set **Password** to the App Password you generated in the previous section
8. Click **Add Account**
9. Verify the account by clicking the link sent to your Gmail

## Final Optional Settings
1. Refresh the [Gmail Accounts and Import Settings](https://mail.google.com/mail/u/0/#settings/accounts) page to see your new, verified email(s)
2. Select **Reply from the same address the message was sent to**
3. Choose a new address to `make default`.

---
layout: post
title: BountyCon Challenge Solution
---

Poking around the web, I randomly found a flag to BountyCon. Cheers!
```shell
$ curl https://www.google.com/.well-known/security.txt
Contact: https://g.co/vulnz
Contact: mailto:security@google.com
Encryption: https://services.google.com/corporate/publickey.txt
Acknowledgements: https://bughunter.withgoogle.com/
Policy: https://g.co/vrp
Hiring: https://g.co/SecurityPrivacyEngJobs
# Flag: BountyCon{075e1e5eef2bc8d49bfe4a27cd17f0bf4b2b85cf}
```
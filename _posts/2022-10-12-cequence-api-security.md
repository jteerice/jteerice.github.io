---
layout: post
title: Bay Area OWASP Meetup - Cequence Security Talk on API Security
---
Event: [October Meet](https://www.meetup.com/bay-area-owasp/events/288939146/)

## Existing Approaches Fall Short
Shadow APIs - unknown

Drivers of API as an attack vector
* insufficient visibility
* insufficient inventory tracking (OWASP API9)
* poor quality assurance
* no formal publication process
* internal APIs publicly exposed

Abuse Examples
* sneaker bots
* third party payment APIs
* credit/gift card checking
* content scraping

APIs and Bots: Inextricably Connected
* OWASP API Top TEN
* API10+: API Abuse that encompasses the different ways a prefectly coded API might be abused

Continuous API Protection Lifecycle - Unified API Protection
* Discovery - Identify ALL Public Facing APIs
* Inventory - Provide Unified Inventory of ALL APIs
* Compliance - Ensure Adherence to Security and Governance Best Practices
* Detection - Detect attacks as they happen
* Prevention - Block attacks natively in real time
* Testing - secure new APIs before go-live

## Real World Stories

### SIM Swapping and Broken Object Level AUTH (OWASP API1)
Stealing your phone without touching it - then gaining access to financial info, etc
If API says can't port phone number over, it means it's already a customer

### Inventory Validation Attack
Local inventory search API targeted by massive attack
Attackers leveraged:
* 3rd party API used to help customers find products locally
* API4 - Lack of resource and rate limiting
* API5 - Broken function level auth

Motivation
* Targeting hot product availability and location for efficient smash and grab shoplifting
* ULTA - There are apps/companies that are like junior doordash/instacart that offer same-day delivery even though no affiliation.

## The Unholy Trinity: Becoming a commonly observed tactic
How it works:
* Validate account via credential stuffing
* Collect information returned
* Use knowledge of APIs to find shadow APIs of similar format
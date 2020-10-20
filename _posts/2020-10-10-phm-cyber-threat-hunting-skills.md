---
layout: post
title: Webinar - Cyber Threat Hunting Skills with Aastha Sahni
---

## Info

Pacific Hackers Meetup - October 10, 2020 - [Cyber Threat Hunting Skills with Aastha Sahni](https://www.meetup.com/pacifichackers/events/272197168).

## Abstract

With the growing number of threats and their complexity, Cyber Threat Hunting has become an important part of Cyber Defense Strategy. We will discuss one such approach today of Cyber Threat Hunting - OODA (Observe,Orient, Decide & Act) Loop and how to use it for detecting real time threats proactively.


## Threat Hunting - OODA Loop

* Threat Hunting Definition
	* Threat hunting is the process of seeking out adversaries before they can successfully execute an attack. The concept of hunting for threats is not new, but many organizations are putting an increased emphasis on programmatic threat hunting in recent times due to malicious actors’ increasing ability to evade traditional detection methods.
* Dwell Time
	* Dwell time is calculated as the number of days an attacker is present in a victim network before they are detected.
	* Threat Hunting aims to reduce dwell time
	* FireEye Mandiant - 2011: 416 days, 2019: 56 days
* Hunt Methodology - OODA Loop
	* Observe
		* Continuous Monitoring of your environment
		* Tracking, like SIEM
			* identify anomalous behavior
		* Tools used - SIEM Alerts, IDS Alerts, Vulnerability Assessment, Application Performance Monitoring 
	* Orient
		* Evaluate whats is going on inside your environment
		* Once abnormalities are identified:
			* Perform Incident triage
			* Analysis and Investigation
			* Threat Intelligence
			* Security Research
			* Risk Assessment
		* Build intuition, make hypotheses about what is happening, predict what could happen next
	* Decide
		* Choose the best action for minimum damage and quick recovery
		* Align with Organization's policies and procedures
		* Hire consultant - obtain recommendations
		* Develop plan to remediate
		* Document all aspects of Incident Response Checklist
	* Act
		* Remediate, Recover, and continuous improvement of incident response plan
		* Security Trainings and communications for future
		* Tools used - system and patch management, backup and recovery, forensic tools
		* Bringing affected systems back to normal functioning
* Building Continuous Intelligence with OODA Loop
	* OODA helps process context info quicker, prioritizing alerts. The loop uses automation to pull in all necessary data across IT assets and services, analyze relevant info, and provide SOC team with what is worth investigating, what may warrant watching over time, and what is effectively "business as normal."

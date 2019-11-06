# Using Desired State Configuration

# Lesson Agenda
Learning about DSC
DSC keywords
How it works
Considerations before use
creating custom moules
working with configurationdata

Section 1: Basic static configuration 
Section 2: Basic multi-server configuration
Section 3: Multi-server configuration with configurationdata
Section 4: Multi-server configuration with logic applied to DSC resources
Section 5: Multi-server configuration with logic applied to roles

# Learning about DSC
## What is dsc
About 5 years ago, microsoft desired a stake in the configuration management workspace and DSC was born.
If you were to boil DSC down to its core components, it is essentially scheduled tasks executing powershell scripts to make itempotent changes to a node

## In a world that is increasingly becoming more container based, where does DSC fall in that pipeline?
DSC is like a really odd-shaped tool. It is certainly not always the perfect fit, but it definitely has its place. When you have any kind of legacy application you need to maintain, DSC does an excellent job at configuring non-container elements in a pipeline in a lightweight manner. 

## What are some of the advantages and disadvantages you get with DSC?

### Advantages
* It's free
* It's native to windows since 2012R2
* It banks off of your existing powershell knowledge
* it is itempotent in nature
* endpoints maintain itempotentcy with or without an active network connection 
* it is what you make of it. It is essentially an engine that can be plugged into other elements in your pipelines

### Disadvantages
* It requires more tooling to stand up than other configuration management utilities (Thus increasing the lead time to production)
* Some elements are not (yet) open source
    * The LCM is not open source yet, but this will change in the future
* Reporting and analytics are more cumbersome and designed to be consumed by other logging products
* You have less options for scheduled deployments

# DSC keywords
|Keyword/*Abbreviation*|Explanation|
|--------------------|-----------|
|Desired State Configuration/*DSC*|An engine builtin to Windows to configure settings on computers|
|Local Configuration Manager/*LCM*|The core engine of DSC builtin to every installation of windows to execute powershell scripts|
|Configuration Data/*CData*|A library of data configurations use to create MOF files|
|DSC Resource|A powershell script |
|DSC Composite Resource|A collection of logically ordered DSC resources to achieve a single objective|
|Managed Object Format/*MOF*|A configuration file nodes use to know and maintain their desired state|
|Meta Managed Object Format/*Meta MOF*|A configuration file nodes use to configure the LCM|
|DSC Checksum|A SHA-256 filehash saved in TXT format. The LCM uses these hashes to determine MOF integrity and execute health checks|
|Node|Any computer, switch, or device you manage with DSC|
|Push/Pull|nodes can be configured to have configurations *pushed* to them, or they can be instructed to *pull* them from somewhere else|

# How it works
Starting with DSC is pretty simple. You write a powershell script that generates MOF files, then distribute those MOF files to target computers.

# Considerations before use
* How will you issue certificates for encrypting and decrypting credentials inside MOFs?
* What will you do when these certs expire?
* How will you handle DSC prerequisites? Think configuring the LCM and joining a domain
* How will you automatically provision and push MOF files out?
* How will you handle failed deployments/reverting a bad configuration?
* How will you distribute and update custom and external DSC resources?
* How will you make sure a pull server (if you elect to use one) stays secure?
* How do you ensure that incorrect data stays out of MOFs?
# Using Desired State Configuration

# Lesson Agenda
* Learning about DSC
* DSC keywords
* How it works
* Considerations before use
* dsc in the real world
* Section 0: Preparing a computer for DSC
* Section 1: Basic static configuration 
* Section 2: Basic multi-server configuration
* Section 3: Multi-server configuration with configurationdata
* Section 4: Multi-server configuration with logic applied to DSC resources
* Section 5: Multi-server configuration with logic applied to roles
* Section 6: The actual scripts
* Section 7: credentials inside DSC

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
* it is essentially an engine. If you can build the rest of the car, or have everything but the engine in an existing car, or hell you want two engines or something then DSC may be a good fit.

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

# DSC in the real world
People usually don't use a push configuration. most people use a pull server. It makes sense why. You get a lot of benefit when you use a pull server. A lot of the previous questions on setup are addressed when you use one. Your pull server becomes the one source for all your configurations.
Products like Puppet and ansible will also use DSC resources to bring a node closer to its desired state.

DSC's itempotency isn't a golden ticket though. It doesn't prevent incorrect data from poisoning your configurations, and it doesn't prevent honest human error. Human error will always exist in the configuration management or any workflow in IT. The conversation is usually "how do we keep people from screwing up or get them to screw up less" when the conversation should be "how do we quickly and easily fix screw-ups?" DSC does an excellent job of answering the second question.

# Configuring the LCM
The LCM is ready to go without changing any settings, but there may be some settings you want to change. Think things like how frequently to apply a configuration.
It's pretty much the same process you would use to apply a DSC configuration.

# Basic, static configurations
We'll start with some basic, easier to read configurations that give you a good picture of what DSC does.
We start by declaring a configuration just like you would a function.
Then you declare what modules with DSC resources you want to use
Then we declare what configurations apply to what computers
then we declare the parameter values
Running this script creates a file that we can copy to a target computer.
Any meddling will be automatically corrected

# Basic, multi-server configurations
You can configure more than one server inside a DSC configuration.
There are some problems with this model
* it's not scalable
* you're more prone to typos and incorrect/inconsistent data

# Configurations with configurationdata
DSC has some builtin logic for ingesting and distributing data. the principle is that there are two layers of data. Node generic and node specific. Node specific data will always overwrite node generic data.

# Resources with logical separation
Having special nodes with special settings is inevitable. You need a way to handle these special computers, or in this case supply data that is different depending on who is using it.

We can do better than this though if we logically separate the DSC resources into chunks or roles that each node can opt into, then supply a combination of node generic and node specific data to each role.

# Where's the powershell though?
Some of you are probably thinking where's the actual powershell? This is just an abstraction.
# Gitting better about source control and powershell

## What is git?
If you've spent anytime in the IT workspace, you've likely heard of Git, or Github, or heard terms like version control, branch, head, pull request, or commit.

## Some commonly used terminology
|Term|Explanation|
|----|-----------|
|Git|Software for managing code|
|Github|A website to manage git repositories|
|Commit|A recoded change|
|Branch|A collection of sequential commits to organize and manage changes|
|Pull request|A request to pull commits from one branch into another|
|Repository|A collection of branches that make up your codebase|
|HEAD|The latest commit of a branch|
|Master|The default branch when you initialize a git repository. Master is often used as the source for production code.|

## My development environment
I'm using Visual Studio Code, Git for windows, and the Powershell module Posh-Git to manage my changes. Familiarity with commands is helpful but is not required. VSCode has a builtin section for managing source control that is very friendly to work in. I'm just more comfortable calling git from the command line. Normally, you don't have any visibility at the command line without calling a command and getting output. The powershell module Posh-Git writes to your command prompt and gives you that visibility.

## Commits
A commit is simply put as a recorded change to one or more text files. The changes are all timestamped and sequentially arranged to form a comprehensive history of your code. You can create a commit by calling "Git Commit" 

## Branches
## Working with remote repositories
Git is all about collaboration. With Git repositories, you have your local copy of code, and then you have the remote copy. Changes can potentially be introduced by someone else's commits and your local copy can get stale. You can 

## working with pull requests

## Merge conflicts
Merge conflicts occur when the same line on the same file has been changed in two different locations. When the changes meet, you have a merge conflict that Git cannot resolve on its own. It needs your input into which change you want to keep.

## Fixing other screw-ups
Most of this stuff you probably won't have to do. 

## Other uncommon commands

## CI/CD, Jenkins, and Powershell
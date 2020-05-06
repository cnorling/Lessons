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
|Git Fetch|Allows you to see changes made to a remote repository.|
|Git Pull|Allows you to pull down changes made to a remote repository. It also allows you to pull changes from one local branch into another local branch.|

## My development environment
I'm using Visual Studio Code, Git for windows, and the Powershell module Posh-Git to manage my changes. Familiarity with commands is helpful but is not required. VSCode has a builtin section for managing source control that is very friendly to work in. I'm just more comfortable calling git from the command line. Normally, you don't have any visibility at the command line without calling a command and getting output. The powershell module Posh-Git writes to your command prompt and gives you that visibility.

## Staging changes
You can stage changes by calling Git Add. It allows you to make multiple changes simultaneously and stage certain ones for a commit. You can also select all the edited files with Git Add *.

## Commits
A commit is simply put as a recorded change to one or more text files. The changes are all timestamped and sequentially arranged to form a comprehensive history of your code. You can create a commit by calling "Git Commit". Each commit requires a brief message that describes the changes you made. You use the -m switch followed by a string to enter your commit message.

### Checking out things other than HEAD
When you checkout a branch, by default it checks out the HEAD of the branch. You can checkout an earlier commit by finding the commit hash with Git Log, copying it, then calling Git Checkout <COMMIT_HASH>

## Branches
## Working with remote repositories
Git is all about collaboration. With Git repositories, you have your local copy of code, and then you have the remote copy. Changes can potentially be introduced by someone else's commits and your local copy can get stale. You can 

## what about the metadata?
Metadata has to be stored somewhere locally. For Git, that location is the folder .git.

## working with pull requests

## Merge conflicts
Merge conflicts occur when the same line on the same file has been changed in two different locations. When the changes meet, you have a merge conflict that Git cannot resolve on its own. It needs your input into which change you want to keep.

## Fixing other screw-ups
Most of this stuff you probably won't have to do. 

## Other uncommon commands

###reflog
reflog lets you look at your recent commit history in a compact format. It's less verbose than git log but it's easier to use.

### Quitting editors
When you call certain commands (like git log), you will be brought into a text editor or browser. You can exit by pressing SHIFT + Q

## CI/CD, Jenkins, and Powershell
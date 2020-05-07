# prerequisites are Git for windows and an account on github. Everything else is just for convenience.

# setup a github repository
# initialize a repository with git clone. You can get the remote URL from a github repository
Set-Location "C:\users\teran.selin\git\"
Git Clone git@github.com:Selin-PDQ/slcpowershell-git.git

# git clone will clone the repository down into a new folder under your current location.

# Let's move into the repository and add some content.
Set-Location "C:\users\teran.selin\git\slcpowershell-git\"

# psreadline activates and starts displaying git info at the prompt
# right now, we have the default branch named master checked out.

# make some changes and save the file
$ourscript = @'
$services = Get-Service
foreach ($service in $services) {
    $service.name
}
'@
new-item -Path .\file.txt -ItemType File -Value $ourscript

# git can now tell that a file has been changed, then PSReadline reads and displays that information.
# we now need to create a commit that records what we've changed.
# first we need to pick what files we want to stage for the commit.
Git add file.txt

# and then we add a commit message that describes the change.
# commit messages should be short and sweet. If it's longer than one or two sentences, break your changes into multiple commits or be less verbose.
Git Commit -m "My first git change!"

# the change is now recorded locally but it's still not on github.
# we need to let github know that we have some new changes and hopefully it will accept them.
# we can do that by calling git push
Git push

# You can create branches locally and then push them to remote
# In my experience, it's easier to just go to github (remote) and create branches there.
# Create a branch named A, then fetch the new branch and check it out
Git fetch
Git checkout a

# make some changes to your script, then save and commit the changes
code .\file.txt
git commit -m "branch A changes"

# Before integrating the changes, let's simulate a merge conflict.
# Create a branch named B, then fetch the branch and check it out
git fetch
git checkout b

# make some changes to the same script on the same line and save+commit+push.
# create a pull request from branch B into master, and merge it.
git add *
git commit -m "branch B changes"

# Since A has not been merged into master yet, B will merge with no conflicts.
# If we open another pull request to integrate A into master, we'll get a merge conflict.
# Merge conflicts occur when the same line in the same file is edited by two different commits in two different branches.
# The real problem is that branch A is out of date. it doesn't have the latest info from master.
# To start the resolution process, checkout branch A and pull the changes from master in.
git checkout a
git pull origin master
code .\file.txt

# vscode's integration with source control makes it easier to visualize changes and resolve merge conflicts.
# decide which change is the real change that needs to be made, then commit your resolution and push it out.
git commit -m "resolving merge conflict"
git push

####################################
# other cool commands and features #
####################################

# reflog gives you a quick overview of your recent commits and provides you with a hash you can checkout.
git reflog

# you can use git checkout on more than branches. If you have a commit's hash, you can check it out to view that point in time.
git checkout {hash}

# if you make a bunch of garbage changes and you want to reset back to the latest commit, you can call git reset --hard
git reset --hard

# vscode has a plugin called GitLens that gives you line by line insight into who made what changes and when.
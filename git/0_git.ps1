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

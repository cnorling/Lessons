# jobs are a way to segment work into chunks that execute in a parallel fashion rather than in a linear fashion.
Get-Command "*job*" -Module @('psscheduledjob','microsoft.powershell.core') | Sort-Object 'module'

# there's a lot of job commands, but let's just start by running a job.
Start-Job {
    Get-ChildItem -Recurse '.\'
}

# the output of most job commands is one or more job objects. 
# These objects are just there to help you organize and ingest the information contained inside a job.
# we can save jobs as variables and look at them later
$job = Start-Job {
    Get-ChildItem -Recurse '.\'
}
$job

# or we can use an explicit command to find the job and get it's status information.
Get-Job -Id 2

# all jobs have a job ID that starts at 1 and increments as you create more of them.
# we can also get a job based on the job's name. By default, the job name is just the job ID prefixed with the word 'Job.
Get-Job -Name 'Job2'

# if you want, you can specify the job's name when you start it to help keep things organized
# you can have duplicate named jobs, so be conscious of that.
Start-Job -Name 'bob' {
    Get-ChildItem -Recurse '.\'
}

Get-Job -Name 'Bob'

# jobs can get really deep and become hard to read inside a script. 
# obfuscate the script block away from the job initialization to help with legibility.

$jobScript = {
    Get-ChildItem -Recurse '.\'
}
Start-Job -Name 'Mob' -ScriptBlock $jobScript

# that's great but I actually need to work with the output of the job. how do I do that?
# Whatever's sent to the output is saved in the job object once the job is marked as complete.
# we can get the output with receive job.

Receive-Job -name 'Mob'

# if you run the same command again, the output is no longer retained.
# you need to either save the output in a variable, or pass the -keep parameter so it holds onto it.

Start-Job -Name 'goneGirl' -ScriptBlock $jobScript
Receive-Job -Name 'goneGirl' -Keep
Receive-Job -Name 'goneGirl'
Receive-Job -Name 'goneGirl' -Keep

# it's also worth noting that if you ever run Receive-Job without the -Keep parameter, it will null out the output regardless of what you ran before. 
# don't forget that jobs take some time to complete. If you're running a script, you might need to wait for one or more jobs to finish before continuing.
# We can use wait-job to do that.
Start-Job -Name 'waiting' -ScriptBlock {'how long do I have to wait?'} | Wait-Job

# if you pass it more than one job, it will wait for them all to complete before continuing.
$numbers = 1..3
$jobs = foreach ($number in $numbers) {
    Start-Job -Name 'waiting' -ScriptBlock {'how long do I have to wait?'}
}
Wait-Job $jobs

# if you run multiple jobs with the same name, and then receive them at the same time, the output will be aggregated into an array.
$numbers = 1..3
$jobs = foreach ($number in $numbers) {
    Start-Job -Name 'mumboJumbo' -ScriptBlock $jobScript
}
Wait-Job $jobs
$finalArray = Receive-Job -name 'mumboJumbo'

# what if the output is just a bunch of nonsense that doesn't match up as easily as the output from get-childitem?
Start-Job -Name 'nonsense' -ScriptBlock {@{key = 'value'}}
Start-Job -Name 'nonsense' -ScriptBlock {'string'}
Start-Job -Name 'nonsense' -ScriptBlock {12321312312}
Wait-Job -Name 'nonsense'
$jumbledNonsense = Receive-Job -name 'nonsense'

# it still generates an array of the output even if it doesn't match up!
# debugging jobs gets tricky. PowerShell has a command called Debug-Job, but it isn't always helpful because of how stringent the criteria are.
# The job needs to be running, and it needs to support debugging. Let's get a long running job going and look at how it works.
Start-Job -name 'debugTest' -ScriptBlock {
    $numbers = 1...60
    foreach ($number in $numbers) {
        Start-Sleep -Seconds 1
        Write-Output $number
    }
}

Debug-Job -Name 'debugTest'

# our output is now bound to the console. We can look at the environment variables and other localized content in the job
# but the job is currently paused because of the debugger, so we can't really spectate what's happening inside the job.
# In my experience, it's honestly easier to just look at the STDOUT from Receive-Job to debug your scripts.
# What does that look like anyways?

$errorJob = Start-Job -Name 'error' -ScriptBlock {
    Get-ChildItem .\
    throw 'boo hiss'
}

# this is a much cleaner way to capture the output of a job you're running and any errors you may run into.
Get-Job -Name 'error' | Receive-Job -Keep

# when you create a job, you're actually creating another separate powershell process that executes the script you feed it.
# as you might expect, you can supply parameters and credentials to that session if need be.
# because these scripts are running on separate processes, you need to understand that they are operating on a different scope from your local session.
# they will start in the same directory they are initiaed from, but they won't have access to any functions you initialize outside of the job.
# for example:

function Try-Stuff {
    param (
        $string
    )
    Write-Output $string
}
Start-Job {
    try-stuff
} | Receive-Job

# the job has no idea that the function Try-Stuff exists, so it errors out.
# the only way around this is to define the function inside the job.

Start-Job {
    function Try-Stuff {
        param (
            $string
        )
        Write-Output $string
    }
    try-stuff 'blag!'
} | Wait-Job | Receive-Job

# if you have a LOT of functions you need to define in a job, it can be helpful to break out your initializaiton functions into a separate script block like this:
$functions = {
    function Try-Stuff {
        param (
            $string
        )
        Write-Output $string
    }
}
$script = {
    try-stuff 'blag!'
}
Start-Job -InitializationScript $functions -ScriptBlock $script | Wait-Job | Receive-Job

# you will have the same problem with variables
$word = 'ahoooga'
Start-Job {
    if ($word -eq $null) {
        throw 'sad days :('
    } else {
        Write-Output $word
    }
} | Wait-Job | Receive-Job

# but there is a workaround! you can use USING to instruct your job to look at the parent session's scope for the correct variable.
$word = 'ahoooga'
Start-Job {
    if ($using:word -eq $null) {
        throw 'sad days :('
    } else {
        $using:word
    }
} | Wait-Job | Receive-Job

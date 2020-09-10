# let's start with a basic script that needs to do one thing multiple times.
# any script that benefits from parallelization starts with an array. 
# A collection of stuff that needs to be processesd in an identical manner.
# we can generate an array like this, but it will take forever to type out 100 integers just for an example.
$numbers = @(
    1
    2
    3
    4
    5
)

# we can specify a range of integers and powershell will generate an array for us!
$numbers = 1..10

# let's plug this range of integers into a generic function.
# we'll design it to take up a signifigant amount of time to highlight the immediate deficiency.
function Simulate-SlowCommand {
    param (
        [int]$inputNumber
    )
    Start-Sleep -Seconds $inputNumber
}

# the problem with this script is pretty obvious. It will take almost a minute to complete this script!
# we can guess how long it takes certain things to execute
# but instead of speculating with figures like "almost 5 minutes", we should make data driven decisions.
# we can get some of this data with this nifty command called measure-command, which will tell us how long this script takes to execute.
$timeToExecute = Measure-Command {
    foreach ($number in $numbers) {
        Simulate-SlowCommand -inputNumber $number
    }
}
$timeToExecute

# you've probably heard this before, but the reason it's running so slow is because all 10 executions of the function are in a linear fashion.
# We need them to execute at the same time.
# If you're using PowerShell 7+, foreach loops are capable of parallelization out of the box.
# If you're on windows and haven't gone out of your way to install PowerShell 7, you're probably on 5.1 which means you're stuck with Jobs.

# We'll start by establishing basic objects, what you can do with them, and how they differ.

1                       # this is an integer, also called int
a                       # this is a character, also called char
'one'                   # this is a string
1.1                     # this is a double
$true                   # this is a boolean

# There are other datatypes, but we don't really need to talk about them for this lesson, and you will probably not need to use them.
# Powershell automatically detects the data types for all the above objects
# there might be occasions where you need to say "no, that's actually a different type."
# you can do that by prefixing the object with the type it should be.

1 -is [int]             # this will come back as true because 1 is an int
'1' -is [int]           # this will come back as false because 1 is in quotes.
[int]'1' -is [int]      # Despite being in quotes, this 1 will be treated as an int because we specified it as an int
[int]'1' + 1 -eq 2      # we can still apply basic arithemetic to it as well!

# this sounds dumb but when I started with powershell I didn't know what the difference between an array and a hashtable was.
# I saw the parenthes and squigglies and for whatever reason thought they were interchangeable.
# It's understandable why someone would get the two confused. They use similar characters to encapsulate the contents
# they are both methods to store data but they certainly are not the same. So what's the difference?

$array      = @()
$hashtable  = @{}

# an array is just a bunch of stuff that is collected in one container. Like a box full of stuff.

@(1,2,3)                # it can be full of similar things
@(1,'two',3)            # it can be full of different things
@(@{},@{},@{})          # it can also be full of hashtables.
@(1)                    # it can just have one thing
@()                     # or it can have nothing.
@(
    @(1,2,3),
    @('a','b','c')      # or it can contain one or more separate arrays
)

# arrays are indexed and remember what order they were assembled in.
# you can reference an object in an array by it's position in the array.
# arrays start at zero, don't buy into that arrays start at 1 funny business
$array = @('a','b','c')
$array[1]

# you can actually do the same thing when working in an array inside an array!
$array = @(
    @(1,2,3),
    @('a','b','c')      # or it can contain one or more separate arrays
)
$array[0][1]

# you can add more content to an array using +=
$array = @('a')
$array += 'b'
$array += 'c'
$array

# it's been talked to death, but using += slows down with larger arrays. The more stuff you have, the worse it gets. 
# You can use something like arraylists instead.
$hundredthousand = 1..100000
$array = @()
$arraylist = [system.collections.arraylist]::new()

Measure-Command {
    foreach ($number in $hundredthousand) {
        $array += $number
    }
}

Measure-Command {
    foreach ($number in $hundredthousand) {
        $arraylist.add($number)
    }
}

# let's talk about hashtables. Hashtables are collections of stuff with corresponding identifiers.
# The identifier is called a key, and the value is called a value.
$car = @{
    topspeed=140
    weight='2200 lbs'
    seats='4'
    make='toyota'
    model='prius'
    gears=@(1,2,3,4,5,'R','NEUTRAL')
}

# The keys in this array are 'top speed, weight, seats, make, model, and gears.
# Instead of referring to the content of the hashtable by position, we can refer to it by key.
$car.topspeed

# If we want, we can create an array by asking the hashtable for all the keys for that hashtable.
$car.keys

# we can also do that for the values.
$car.Values

# how do these objects translate to something like a csv?
$laptops = @{
    make = @('lenovo','dell','hp')
    model = @('x220','e110','garbage')
    age = @('10 years','12 years','eternity')    
}
export-csv -InputObject $laptops -Path 'C:\users\teran.selin\Desktop\laptops.csv'
& C:\users\teran.selin\Desktop\laptops.csv
# why didn't that work?

$laptops = @(
    @{
        make = 'lenovo'
        model = 'x220'
        age = '10 years'
    }
    @{
        make = 'dell'
        model = 'e110'
        age = '12 years'
    }
    @{
        make = 'hp'
        model = 'garbage'
        age = '100 years'
    }
)

# it helps to picture things like excel spreadsheets as an array of hashtables. 
# Each row is a hashtable, and each column is the value that applies to that hashtable.

export-csv -InputObject $laptops -Path 'C:\users\teran.selin\Desktop\laptops.csv'
& C:\users\teran.selin\Desktop\laptops.csv
$csv = Import-Csv -Path C:\users\teran.selin\Desktop\laptops.csv
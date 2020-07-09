# Powershell has the ability to save basic data structures and use them over time. 
# Things like CSVs, XML, and JSON all serve as methods to data between powershell sessions.
# If you need an advanced data structure though, there's a module called datum that lets you work with advanced nested sets of data.
# I have used it previously for configuration management with DSC.
# It was originally developed for use with DSC, but it capable of servicing more functions than that.

# datum at its roots is a way to stack data in an order of precedence.
# A good use case for datum is server configuration.

cd 'C:\users\teran.selin\git\lessons\datatypes\bin\datum_1'
$datum = New-DatumStructure -DefinitionFile '.\datum.yml'

# datum is comprised of slices of data in yaml that are composed to create a high density view of data.
# datum also has a manifest file that dictates what order we ingest the slices, and how we handle specific types of data.
# In our example, we have two slices, the bottom and the top.
# In the bottom slice, we have a number and a letter, and in the top slice, we have a number that needs to take precedence over the letter.
# We've specified in datum.yml that the top slice takes precedence, so when we do a lookup we'll get the content from the top slice overlayed.

lookup 'specs' -datumtree $datum

# We were able to make a change to the set of data without disturbing the base set of data.
# This isn't a practical example, it's just meant to illustrate how you can stack slices of data and have them take precedence.
# In the next example, you'll get a better look at how you can actually utilize this slicing to your advantage.

cd 'C:\users\teran.selin\git\lessons\datatypes\bin\datum_2'
$datum = New-DatumStructure -DefinitionFile '.\datum.yml'

# this time, the data is a set of specifications for a server. We have a basic idea of what a generic server should look like.
# We have also defined in the top layer what the settings for a specific server we have in mind should look like.

lookup 'specs' -datumtree $datum -node 'SERVER-01'

# Datum has a builtin feature where you can supply a keyword to the -node parameter. This allows you to introduce logic into which layers will and will not apply to the server.
# If we do a lookup without specifying a server's name, we get the regular result we would expect.

lookup 'specs' -DatumTree $datum

# But if we do a lookup with the node's name, we get the results we specified in the topmost layer.
# This works well, but it doesn't work for all the potential types of data that you work with. What if you have an array, and you want to add objects to it instead of deleting it?
# A good example of that need is hard disks.

cd 'C:\users\teran.selin\git\lessons\datatypes\bin\datum_3'
$datum = New-DatumStructure -DefinitionFile '.\datum.yml'

# In this example, I have the same logic I had in the previous example, but I've added an array of hard disks to the equation.
# We need to retain the inheritance behavior we got with the other sections of data, but we also need to somehow merge these two arrays.
# The only solution we really have to this problem is to explicitly declare that key as one that needs to be merged together.
# We can do that in datum.yml

lookup 'specs' -DatumTree $datum -Node 'SERVER-01'

# honestly some of the configuration options for this datum module are beyond me. I can't wrap my head around knockout prefixes and deeptuple keys.
# there's one other cool feature with datum that I did get to experiment with previously, and it's called data handlers.
# The idea of data handlers is sometimes you don't want stuff saved in the yaml documents like passwords.
# But you still need that data. Data handlers enable you to watch the slices for specific keywords, and then run arbitrary script content when that keyword is detected.
# A good example of that would be having the placeholder text CREDENTIAL_VMWARE. 
# Then you build a data handler that pulls the password from a vault and replaces the text with the credentials.
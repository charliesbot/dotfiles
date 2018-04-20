# open dirvish at current file
-

# reload the dirvish buffer
R

# create a file
:e %foo.text

# create a directory
:!mkdir %foo

# delete a file
x
:Shdo rm {}
Z!

# delete a directory
x
:Shdo rmdir {}
Z!

# rename a file
x
:Shdo mv {} prefix-{}-suffix
Z!

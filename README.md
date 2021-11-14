# Bulkstamp - Bulk rename to creation time
\
**What is Bulkstamp?**\
Bulkstamp is a short bash script to rename all files in a chosen directory to the file's creation timestamp. For this script to work properly, files must have been assigned a creation date by the filesystem.\
\
\
**How does Bulkstamp work?**\
This is what the script does, step-by-step:
- Ask the user for the directory to operate in (no recursive option yet, all default options are between [] ),
- Ask the user for a description to add to the new filename (optional),
- Let the user choose to keep old file extensions or to change all extensions to a new one,
- Enter the working directory and work on one file at a time:
  - Memorize the old name and the new extension (for the next point: multiple runs of the script could end up in overlapping names),
  - Setup empty variables for a convention in case of name collisions (add a number at the end),
  - (check line 32),
  - Grab the old extension,
  - Allocate file location and temporary variables,
  - Setup the new filename,
  - Check for collisions before renaming (in which case increment a %03d value at the end),
  - Finally move the file to to the same directory and with a new name,
  - Repeat until all files have been renamed,
- Tell the user how many files have been renamed and exit.
<!-- -->
\
**Can I use Bulkstamp in my project/whatever?**\
Absolutely. This script is published under the MIT license. Please always keep a backup of any important data whenever possible.

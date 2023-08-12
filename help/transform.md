# Transform Plugin

This plugin for the micro editor provides some text transformations

## Included Commands
There are no keybindings set, you have to add them manually if you need them. All command work on the current selection or, if nothing is selected, on the whole file. This plugin has no configuration and none of the commands have arguments.

list of commands:
| command name         | description                                                                |
| -------------------- | -------------------------------------------------------------------------- |
| unique               | keeps only unique lines, simmilar to uniq commandline tool without sorting |
| sort                 | sorts all lines                                                            |
| trim-right           | trim whitespace at the end of the line(s)                                  |
| trim-left            | trim whitespace at the start of the line(s)                                |
| trim                 | trim whitespace at both ends of the line(s)                                |
| csv-to-table         | converts comma separated values into table format                          |
| csv-equal-with       | inserts spaces to mace all columns in a CSV file the same length           |
| table-to-csvcsv-trim | trims whitespaces in CSV files (undoes csv-equal-with)                     |


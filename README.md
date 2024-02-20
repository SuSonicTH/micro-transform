# Transform Plugin

This plugin for the micro editor provides some text transformations

## Included Commands
There are no keybindings set, you have to add them manually if you need them.
All commands work on the current selection or, if nothing is selected, on the whole file.
This plugin has no configuration and none of the commands have arguments.

list of commands:

| command name                | description                                                                                 |
| --------------------------- | ------------------------------------------------------------------------------------------- |
| unique                      | keeps only unique lines, simmilar to uniq commandline tool without sorting                  |
| sort                        | sorts all lines                                                                             |
| trim-right                  | trim whitespace at the end of the line(s)                                                   |
| trim-left                   | trim whitespace at the start of the line(s)                                                 |
| trim                        | trim whitespace at both ends of the line(s)                                                 |
| csv-to-table                | converts comma separated values into table format                                           |
| csv-equal-with              | inserts spaces to make all columns in a CSV file the same length                            |
| csv-trim                    | trims whitespaces in CSV files (undoes csv-equal-with)                                      |
| table-to-csv                | converts a (markdown) table to csv format                                                   |
| table-format                | reformats (equals widths) of an existing markdown table                                     |
| lines-to-list               | converts multiple lines into a single line replacing newline with comma                     |
| lines-to-list-quoute-double | same as lines-to-list but puts each lines value into double quoutes                         |
| lines-to-list-quoute-sinlge | same as lines-to-list but puts each lines value into single quoutes                         |
| lines-to-string             | converts lines to a double quoted string, escapes backslash,double quoutes, tab and newline |
| lines-to-string-block       | same as lines-to-string but keeps one string per line concatenated with +                   |


## Installation
add `https://raw.githubusercontent.com/SuSonicTH/micro-transform/master/repo.json` as a repo to your ~/.config/micro/settings.json

sample setting.json
```json
{
    "pluginrepos": [
        "https://raw.githubusercontent.com/SuSonicTH/micro-transform/master/repo.json"
    ]
}
```

then you can install the plugin from the commandline with following command:

```bash
micro -plugin install transform
```

or, after restarting micro, execute following commant with *Ctrl-e*
```
plugin install transform
```

Alternativley you can just download  all files from the repository and put them under `~/.config/micro/plug/transform`

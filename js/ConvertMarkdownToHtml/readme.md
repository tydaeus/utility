# ReadMe - ConvertMarkdownToHtml

This project aims to provide a relatively simply and easy-to-use utility for converting markdown documents to html.

## Usage - Commandline
Use `node main FILE1...` to invoke the script on one or more files. An html file will be generated for each specified file, within the same directory.

Files not ending in the `.md` extension will be ignored.

Directories specified will have all their `.md` contents converted; subdirectories of specified directories will only be converted if the `--recurse` option is specified.

### Options
Commandline options are still under development. Supported options:

* `--recurse` - all subdirectories of specified directories will also be converted.
* `--test` - runs any in-progress experimental code
* `--local-css` - copies the css stylesheet into each directory where html files are being generated, and links the generated files to that copy(s). If this is not specified, the stylesheet is embedded in each generated file, which can be space-intensive.
* `--canonical` - restrict markdown to html conversion to only the elements defined in  [commonmark](https://commonmark.org/)


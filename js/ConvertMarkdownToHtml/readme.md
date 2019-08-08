# ReadMe - ConvertMarkdownToHtml

This project aims to provide a relatively simply and easy-to-use utility for converting markdown documents to html.

## Usage - Commandline
Use `node main FILE1...` or `convertmarkdowntohtml.cmd FILE1...` to invoke the script on one or more files. An html file will be generated for each specified file, within the same directory.

Files not ending in the `.md` extension will be ignored.

Directories specified will have all their `.md` contents converted; subdirectories of specified directories will only be converted if the `--recurse` option is specified.

### Options
Commandline options are still under development. Supported options:

* `--recurse` - all subdirectories of specified directories will also be converted.
* `--test` - runs any in-progress experimental code
* `--local-css` - copies the css stylesheet into each directory where html files are being generated, and links the generated files to that copy(s). If this is not specified, the stylesheet is embedded in each generated file, which can be space-intensive.
* `--canonical` - restrict markdown to html conversion to only the elements defined in the [commonmark spec](https://commonmark.org/)



## What happens during Conversion?

### Markdown is Converted to Html
Markdown elements defined in the [commonmark spec](https://commonmark.org/) are converted from markdown to html. Html is left untouched, unless it is a custom directive.

### The Stylesheet is Attached
The stylesheet is either embedded in the generated html document (default) or copied to the html document's directory and referenced by link (`--local-css`).  

### Custom Directives are Processed
The custom markdown directives listed below will be processed to generate html or modify converted html, unless the `--canonical` flag has been specified.

#### Directive: Table of Contents
The Table of Contents (TOC) directive (`<!--TOC-->`) will be replaced with a bulleted list of links to subsequent headings.

Each heading will be prefixed with symbol that will contain a link to that heading (for easy copy-paste).

E.g.:
```md
# Title

## Table of Contents
<!--TOC-->

# Heading 1
...
# Heading 2
...
## Subheading 2.1
...
```

Would result in something like:

```html
<h1>Title</h1>
<h2>Table of Contents</h2>
<ul>
    <li>Heading 1</li>
    <li>Heading 2</li>
    <ul>
        <li>Subheading 2.1</li>
    </ul>
</ul>
...
```

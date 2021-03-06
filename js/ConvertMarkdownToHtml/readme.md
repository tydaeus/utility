# ReadMe - ConvertMarkdownToHtml

This project aims to provide a relatively simply and easy-to-use utility for converting markdown documents to html.

## Usage - Commandline
Use `node main FILE1...`, `convertmarkdowntohtml.cmd FILE1...`, or `convertmarkdowntohtml.exe FILE1...` (if packaged as an executable) to invoke the script on one or more files. An html file will be generated for each specified file, within the same directory as the source file.

Files not ending in the `.md` extension will be ignored.

Directories specified will have all their `.md` contents converted; subdirectories of specified directories will only be converted if the `--recurse` option is specified.

## Usage - Windows Explorer
Drag one or more `.md` source files or folders onto `convertmarkdowntohtml.cmd` or `convertmarkdowntohtml.exe`. Corresponding `.md.html` files will be generated in the same dir as the source files. Non-`.md` files will be ignored.

### Options
Commandline options are still under development. Supported options:

* `--recurse` - all subdirectories of specified directories will also be converted.
* `--test` - runs any in-progress experimental code
* `--local-css` - copies the css stylesheet into each directory where html files are being generated, and links the generated files to that copy(s). If this is not specified, the stylesheet is embedded in each generated file, which can be space-intensive.
* `--canonical` - restrict markdown to html conversion to only the elements defined in the [commonmark spec](https://commonmark.org/)



## What happens during Conversion?

### Markdown is Converted to Html
Markdown elements defined in the [commonmark spec](https://commonmark.org/) are converted from markdown to html. Html is left untouched, unless it is a custom directive.

### The Stylesheets are Attached
Stylesheets are either embedded in the generated html document (default) or copied to the html document's directory and referenced by link (`--local-css`).  

### Links to .md Source Files are Redirected
Links to `.md` files are redirected to corresponding `.md.html` files unless `--canonical`.

### Code Blocks are Highlighted
Unless the `--canonical` flag is specified, code blocks denoted by code fences are highlighted via highlightjs, per the language specified at the fence start. If no language is specified, highlightjs will be used to guess appropriate language.

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

## Packaging as an .exe
This script can be packaged as an executable by using the node `pkg` utility. Install globally via `npm install pkg -g`, then use `pkg` via the `pkg_me.cmd` script or a customized variant.
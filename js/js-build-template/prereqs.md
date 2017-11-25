# Prerequisites
The following prerequisite tools must be installed globally within access of
your user account before you'll be able to really use this project. 

## NodeJS and NPM
This project requires nodejs and the NPM package management utility, both
installed by the node installer.

Download from https://nodejs.org/en/download/.

NPM will only be used for global dependencies; yarn will be used for project dependencies.

## Grunt-CLI
Grunt is the primary build tool used in this project.

Use `npm install -g grunt-cli` to install the grunt commandline interface, for 
use on this and all projects. (After npm has been installed).

## Yarn
Yarn provides package management for this project's front-end dependencies.

Install from https://yarnpkg.com/en/docs/install.

## Optional Prereqs

### http-server
http-server can be used as a test server to verify that the template works correctly. Install via 
`npm install -g http-server`. Use via `http-server frontend/public/apps/demo/demo.index.html`.
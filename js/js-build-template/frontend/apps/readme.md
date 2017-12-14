# About apps/

Each SPA-style applications should get placed in this folder.

## Index files
Each application should have an index file for use as the entry point into the application. The default application
should name its index `index.html`, while other applications should name their index `appname.index.html`. Each
application's index file should reference the js entry point for that application in a script tag.

## JS app files
Each application should provide a javascript file named along the lines of `appname.app.js`, which should `require()`
any additional js files needed by the application. Browserify will bundle the requirements with the app.js file as part
of the build process.
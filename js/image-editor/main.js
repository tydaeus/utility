const electron = require("electron");

console.log("starting app");

// control electron lifecycle
const {app} = electron;

const {BrowserWindow} = electron;

// persistent var for window so it doesn't get gc'd
let win;


function createWindow() {
    console.log("createWindow()");

    // create the browser window
    win = new BrowserWindow({width: 800, height:600});

    console.log("__dirname:", __dirname);

    let filePath = "file://" + __dirname + "/public/index.html";
    // load index.html
    win.loadURL(filePath);

    // open dev tools
    // win.webContents.openDevTools();

    // dereference window object; if multiple windows, make sure to delete the closed one
    win.on("closed", () => {
        console.log("window closed");
        win = null;
    });
}

app.on("ready", createWindow);

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") {
        console.log("quitting application");
        app.quit();
    }
});

app.on("activate", () => {
    // support Mac convention of allowing the app to persist without windows, and open a window for the app on re-focus
   if (win === null) {
       createWindow();
   }
});

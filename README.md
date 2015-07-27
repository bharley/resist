# Resist

[![Build Status](https://img.shields.io/travis/bharley/resist.svg?style=flat-square)](https://travis-ci.org/bharley/resist)

A websocket version of [The Resistance].

## Setup
This software uses [io.js]. Installing io.js is beyond the scope of this
readme, but I suggest using [nvm].

(_This might run fine under the standard Node.js, but I haven't tried._)

1. Download the project or check it out with git
2. Install the project dependencies: `npm install --production`
3. Start the server: `npm start`
4. Navigate to the game from your browser: `http://localhost:3000`

## Development
Installing the dependencies without the production flag (i.e., `npm install`)
will allow you to run the tests and do other development-y things. I suggest
installing [CoffeeScript] globally (i.e., `npm install -g coffee-script`) to
have easy access to the REPL.

### Front-end
The front end assets are also written in CoffeeScript using [Angular.js] as
the framework. All of the front-end assets (CoffeeScript, [Sass], views, etc.)
are minified with [Gulp].

### npm Scripts
To make development simpler, there are three custom scripts added to npm:

- `start-dev`: Starts a server with [`supervisor`][supervisor] that restarts
  the server on changes
- `g`: Runs Gulp
- `gw`: Runs Gulp with the `watch` task

You can run these scripts with `npm run-script [script]`


[The Resistance]: https://en.wikipedia.org/wiki/The_Resistance_(game)
[io.js]: https://iojs.org/
[nvm]: https://github.com/creationix/nvm
[Node.js]: https://nodejs.org/
[CoffeeScript]: http://coffeescript.org/
[Angular.js]: https://angularjs.org/
[Sass]: http://sass-lang.com/
[Gulp]: http://gulpjs.com/
[supervisor]: https://github.com/petruisfan/node-supervisor
# Resist
A websocket version of [The Resistance].

## Setup
This software uses [io.js]. Installing io.js is beyond the scope of this
readme, but I suggest using [nvm].

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
are minified with [Gulp]. It's usually easiest to develop with Gulp running
in the background using the `gulp watch` command.

[The Resistance]: https://en.wikipedia.org/wiki/The_Resistance_(game)
[io.js]: https://iojs.org/en/index.html
[nvm]: https://github.com/creationix/nvm
[CoffeeScript]: http://coffeescript.org/
[Angular.js]: https://angularjs.org/
[Sass]: http://sass-lang.com/
[Gulp]: http://gulpjs.com/

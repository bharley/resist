gulp       = require 'gulp'
sort       = require 'sort-stream'
coffee     = require 'gulp-coffee'
sass       = require 'gulp-sass'
uglify     = require 'gulp-uglify'
concat     = require 'gulp-concat'
rename     = require 'gulp-rename'
sourcemaps = require 'gulp-sourcemaps'
plumber    = require 'gulp-plumber'
angular    = require 'gulp-angular-templatecache'

# Paths that we'll need for various tasks
paths =
  sass:
    input:  'src/assets/sass/**/*.scss'
    output: 'build/css'
  coffee:
    input:  'src/assets/coffee/**/*.coffee'
    output: 'build/js'
  partials:
    input:  'src/assets/views/**/*.html'
    output: 'build/js'

# Helper for sorting CoffeeScript files into one file
coffeePriorityPattern = /\/app\.coffee/i
prioritizeStream = (a, b) ->
  aRank = if a.path.match(coffeePriorityPattern) then 0 else 1
  bRank = if b.path.match(coffeePriorityPattern) then 0 else 1
  return aRank - bRank

# Task for transpiling and concatenating Sass files
gulp.task 'sass', ->
  gulp.src paths.sass.input
    .pipe plumber()
    .pipe sourcemaps.init()
    .pipe sass(outputStyle: 'compressed')
    .pipe rename(suffix: '.min')
    .pipe sourcemaps.write('.')
    .pipe gulp.dest(paths.sass.output)

# Task for transpiling and concatenating CoffeeScript files
gulp.task 'coffee', ->
  gulp.src paths.coffee.input
    .pipe plumber()
    .pipe sort(prioritizeStream)
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe concat('app.min.js')
    .pipe uglify()
    .pipe sourcemaps.write('.')
    .pipe gulp.dest(paths.coffee.output)

# Task for handling the Angular.js views
gulp.task 'partials', ->
  gulp.src paths.partials.input
    .pipe plumber()
    .pipe angular(module: 'resist')
    .pipe uglify()
    .pipe rename('partials.min.js')
    .pipe gulp.dest(paths.partials.output)

# Task for watching changes
gulp.task 'watch', ->
  gulp.watch paths.sass.input,     ['sass']
  gulp.watch paths.coffee.input,   ['coffee']
  gulp.watch paths.partials.input, ['partials']

# Task aliases
gulp.task 'build',   ['sass', 'coffee', 'partials']
gulp.task 'default', ['build']

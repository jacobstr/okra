gulp = require 'gulp'
coffee = require 'gulp-coffee'
sourcemaps = require 'gulp-sourcemaps'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
mocha = require 'gulp-spawn-mocha'
ast = require 'gulp-ast'
run = require 'gulp-run'

gulp.task 'build:src', ['build:parser'], ->
  gulp.src('src/*.coffee')
    .pipe(coffee()).on('error', gutil.log)
    .pipe(gulp.dest('./js'))

gulp.task 'build:index', ->
  gulp.src('index.coffee')
    .pipe(coffee()).on('error', gutil.log)
    .pipe(ast.parse())
    .pipe(ast.rewriteRequire((name) ->
      if (name[0...5] == './src')
        return './js' + name[5..]
    ))
    .pipe(ast.render())
    .pipe(gulp.dest('./'))

gulp.task 'build:parser:js', (done) ->
  run('pegjs src/tags.pegjs js/tagparser.js').exec(done)

gulp.task 'build:parser', (done) ->
  run('pegjs src/tags.pegjs src/tagparser.js').exec(done)


gulp.task 'build', ['build:index', 'build:src', 'build:parser', 'build:parser:js']

gulp.task 'test', ['build'], ->
  gulp.src('test/test.coffee', {read: false})
    .pipe(mocha())

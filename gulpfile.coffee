gulp = require 'gulp'
coffee = require 'gulp-coffee'
spawn = (require 'child_process').spawn
sourcemaps = require 'gulp-sourcemaps'
mocha = require 'gulp-mocha'
require 'coffee-script/register'
istanbul = require 'gulp-coffee-istanbul'

jsFiles = []
coffeeFiles = ['src/*.coffee']
specFiles = ['test/*.coffee']

gulp.task 'coverage', ->
    gulp.src jsFiles.concat coffeeFiles
        .pipe istanbul
            includeUntested: true
        .pipe istanbul.hookRequire()
        .on 'finish', ->
            gulp.src specFiles
                .pipe mocha
                    reporter: 'spec'
                .pipe istanbul.writeReports
                    dir: '.',
                    reporters: ['cobertura']

gulp.task 'build', ['coffee']

gulp.task 'coffee', ->
    gulp.src coffeeFiles
        .pipe sourcemaps.init()
        .pipe coffee {bare: true}
        .pipe sourcemaps.write '.'
        .pipe gulp.dest './lib'

gulp.task 'watch', ['coffee'], ->
    gulp.watch coffeeFiles, ['coffee']

gulp.task 'default', ['watch']


gulp = require('gulp')
mocha = require('gulp-mocha')

gulp.task 'default', ['test', 'watch']

gulp.task 'watch', ()->
  gulp.watch '{src,test}/*{,*/*}', ['test']

gulp.task 'test', ()->
  gulp.src ['test/*.test.coffee']
  .pipe mocha
    reporter: 'spec'
    ui: 'bdd'
    compilers: 'coffee:coffee-script/register'
  .on('error', console.warn.bind(console))

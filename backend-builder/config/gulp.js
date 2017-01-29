var spawn = require('child_process').spawn;
var gutil = require('gulp-util');

gulp.task('default', function(){

    gulp.watch('*.js', function(e) {
        // Do run some gulp tasks here
        // ...

        // Finally execute your script below - here "ls -lA"
        var child = spawn("ls", ["-lA"], {cwd: process.cwd()}),
            stdout = '',
            stderr = '';

        child.stdout.setEncoding('utf8');

        child.stdout.on('data', function (data) {
            stdout += data;
            gutil.log(data);
        });

        child.stderr.setEncoding('utf8');
        child.stderr.on('data', function (data) {
            stderr += data;
            gutil.log(gutil.colors.red(data));
            gutil.beep();
        });

        child.on('close', function(code) {
            gutil.log("Done with exit code", code);
            gutil.log("You access complete stdout and stderr from here"); // stdout, stderr
        });


    });
});

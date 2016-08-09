gulp = require 'gulp'
$ = require('gulp-load-plugins')()
fs = require 'fs'
join = require('path').join
ChromeExtension = require 'crx'

gulp.task 'build:coffee', ->
    gulp.src 'src/**/*.coffee'
        .pipe $.coffee()
        .pipe gulp.dest 'dist'

gulp.task 'build:sass', ->
	gulp.src 'src/**/*.scss'
		.pipe $.postcss([
			require('precss')(import: extension: 'scss')
		])
		.pipe $.rename (x) -> x.extname = '.css'
        .pipe gulp.dest 'dist'

gulp.task 'build:pug', ->
    gulp.src 'src/**/*.jade'
        .pipe $.pug()
        .pipe gulp.dest 'dist'

gulp.task 'copy:manifest', ->
    gulp.src 'src/manifest.json'
        .pipe gulp.dest 'dist'

gulp.task 'copy:images', ->
    gulp.src 'src/**/*.png'
        .pipe gulp.dest 'dist'

gulp.task 'copy:libs', ->
    gulp.src [
            'vendor/jquery/dist/jquery.min.js'
        ]
        .pipe gulp.dest 'dist/libs'

gulp.task 'build', gulp.parallel([
        'copy:libs'
        'copy:images'
        'copy:manifest'
        'build:coffee'
        'build:sass'
        'build:pug'
    ])

gulp.task 'serve:zip', (done) ->
    crx = new ChromeExtension    
        privateKey: fs.readFileSync(join(__dirname, "key.pem"))
    crx.load(join(__dirname,'dist'))
        .then ->
            crx.pack()
                .then (crxBuffer) ->
                    fs.writeFile join(__dirname,'bin','extension.crx'), crxBuffer, (err) ->
                        console.log err if err 
                        done()

gulp.task 'default', gulp.series [
    'build', 'serve:zip'
]
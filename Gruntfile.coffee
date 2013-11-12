path = require 'path'


module.exports = (grunt) ->
  for key of grunt.file.readJSON('package.json').devDependencies
    if key isnt 'grunt' and key.indexOf('grunt') is 0
      grunt.loadNpmTasks key
  
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    browserify:
      dev:
        src: [
          'app/scripts/modules/grooveshark-streaming/index.js'
          'app/scripts/modules/node-ytdl/lib/index.js'
        ]
        dest: 'src/scripts/modules.js'
        options:
          alias: [
            'app/scripts/modules/grooveshark-streaming/index.js:grooveshark-streaming'
            'app/scripts/modules/node-ytdl/lib/index.js:ytdl'
          ]
          transform: [ 'coffeeify' ]

    coffee:
      options:
        bare: true
      dev:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: 'app/scripts/'
          src: [
            '**/*.coffee'
            '!modules/**/*.coffee'
          ]
          dest: 'src/scripts/'
          ext: '.js'
        ]

    jade:
      options:
        pretty: true
      dev:
        files: [
          expand: true
          cwd: 'app/'
          src: [
            '*.jade'
            'views/**/*.jade'
          ]
          dest: 'src/'
          ext: '.html'
        ]

    less:
      dev:
        options:
          yuicompress: false
        files: [
          expand: true
          cwd: 'app/styles/'
          src: [ '**/*.less' ]
          dest: 'src/styles/'
          ext: '.css'
        ]

    copy:
      dev_resources:
        files: [
          expand: true
          dot: true
          cwd: 'app/'
          dest: 'src/'
          src: [
            '**/*'
            '!bower_components/**/*'
            'bower_components/bootstrap/dist/css/bootstrap.css'
            'bower_components/font-awesome/css/font-awesome.css'
            'bower_components/font-awesome/fonts/**/*'
            'bower_components/jquery/jquery.js'
            'bower_components/bootstrap/dist/js/bootstrap.js'
            'bower_components/angular/angular.js'
            'bower_components/angular-route/angular-route.js'
            'bower_components/angular-resource/angular-resource.js'
            '!assets/**/*'
            '!scripts/**/*.coffee'
            '!scripts/lib/node_modules/**/*'
            '!styles/**/*.less'
            '!views/**/*.jade'
            '!*.jade'
          ]
        ]

    watch:
      dev_scripts:
        files: [ 'app/scripts/**/*.coffee' ]
        tasks: [ 'coffee:dev' ]
      dev_styles:
        files: [ 'app/styles/**/*.less' ]
        tasks: [ 'less:dev' ]
      dev_views:
        files: [
          'app/*.jade'
          'app/views/**/*.jade'
        ]
        tasks: [ 'jade:dev' ]
      dev_assets:
        files: [ 'app/assets/*' ]
        tasks: [ 'copy:assets' ]

    clean: 
      dev: [ 'src/' ]

    forge:
      ios_build:
        args: [ 'build', 'ios' ]
      ios_sim:
        args: [ 'run', 'ios' ]
      ios_device:
        args: [ 'run', 'ios', '--ios.device', 'device' ]
      ios_package:
        args: [ 'package', 'ios' ]
      web_build:
        args: [ 'build', 'web' ]
      web_run:
        args: [ 'run', 'web' ]


  grunt.registerTask 'default', [
    'build'
  ]

  grunt.registerTask 'build', [
    'clean:dev'
    'browserify:dev'
    'coffee:dev'
    'jade:dev'
    'less:dev'
    'copy:dev_resources'
    'forge:ios_build'
  ]

  grunt.registerTask 'dev', [
    'build'
    'forge:ios_sim'
    'watch'
  ]

  grunt.registerTask 'device', [
    'build'
    'forge:ios_device'
    'watch'
  ]

  grunt.registerTask 'ipa', [
    'build'
    'forge:ios_package'
  ]

  grunt.registerTask 'web', [
    'build'
    'forge:web_build'
    'forge:web_run'
    'watch'
  ]

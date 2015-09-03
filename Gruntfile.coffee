module.exports = (grunt) ->

  grunt.initConfig

    coffee:
      compile:
        files: 'test/indexSpec.js': ['test/*.coffee']

    uglify:
      my_target:
        files:
          'index.min.js': 'src/index.js'

    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coverage/blanket'
        src: ['test/**/*.js']
      coverage:
        options:
          reporter: 'html-cov'
          quiet: true
          captureFile: 'coverage/coverage.html'
        src: ['test/**/*.js']

    blanket:
      options:
        pattern: 'src/index.js'
        'data-cover-never': 'node_modules'

    watch:
      files: '**/*.coffee'
      tasks: ['test']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.loadNpmTasks('grunt-blanket')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('build', ['coffee', 'uglify'])
  grunt.registerTask('test', ['mochaTest', 'blanket'])
  grunt.registerTask('default', ['build', 'test'])

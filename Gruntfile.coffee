module.exports = (grunt) ->
  # Add the grunt-mocha-test tasks.
  grunt.loadNpmTasks "grunt-mocha-test"
  grunt.loadNpmTasks "grunt-contrib-watch"

  # Configure a mochaTest task
  grunt.initConfig
    mochaTest:
      test:
        options:
          reporter: "spec"
          require: [
            "coffee-script/register"
            "test/common.coffee"
          ]
        src: ["test/test.coffee"]
    watch:
      scripts:
        files: ['lib/*.coffee', 'lib/*.pegjs', 'test/*.coffee']
        tasks: ['mochaTest']

  grunt.registerTask "default", "mochaTest"
  grunt.registerTask "default", "watch"
  return

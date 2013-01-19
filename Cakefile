{spawn, exec} = require 'child_process'
sys = require 'util'

printOutput = (process) ->
  process.stdout.on 'data', (data) -> sys.print data
  process.stderr.on 'data', (data) -> sys.print data
  
watchJS = ->
  # coffee = exec 'coffee -r coffeescript-growl -cw -o ./ src/'
  coffee = exec 'coffee -cw -o ./ src/'
  printOutput(coffee)

task 'watch', 'Watches all coffeescript files for changes', ->
  watchJS()
  
task 'docs', 'Create documentation using Docco', ->
  docco = exec """
    docco src/lib/*.coffee
  """
  printOutput(docco)

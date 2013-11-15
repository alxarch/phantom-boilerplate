{spawn, exec} = require 'child_process'

task 'watch', 'Watch for change.', ->
	cs = spawn 'node_modules/.bin/coffee', ['-c', '-w', '-o', 'lib/', 'src/']
	cs.stdout.pipe process.stdout
	cs.stderr.pipe process.stderr

task 'build', 'Build coffee.', ->
	exec 'node_modules/.bin/coffee -c -o lib/ src/'

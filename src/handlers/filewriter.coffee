{join, dirname} = require('../path')
fs = require 'fs'

module.exports = (dir, options = {}) ->
	processData = options.processData
	unless typeof processData is 'function'
		processData = (data) -> data 

	(path) ->
		path = join dir, path

		if fs.isDirectory path
			@reject "Cannot write to #{path}, it's a directory."
		else unless fs.isFile path and fs.Writable path
			@reject "Cannot write to #{path}."
		else
			fs.makeTree dirname path
			fs.write path, processData(data), options.mode
			@resolve path
	
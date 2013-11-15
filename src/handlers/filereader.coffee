{join} = require('../path')
fs = require 'fs'

module.exports = (dir, options = {}) ->
	processData = options.processData
	unless typeof processData is 'function'
		processData = (data) -> data 

	(path) ->
		path = join dir, path
		if fs.isDirectory path
			@reject "Cannot read #{path}, it's a directory."
		else unless fs.isFile path
			@reject "No file does not exist at #{path}."
		else unless fs.isReadable
			@reject "Cannot read #{path}."
		else
			data = fs.read path
			
			@resolve data, path
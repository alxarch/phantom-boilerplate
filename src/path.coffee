fs = require 'fs'

trim = (p) -> p.replace /(^[\/\\]|[\/\\]$)/g, ''
module.exports =
	trim: trim
	dirname: (path) ->
		path.replace /^(.*\/)([^\/]*)$/, '$1'
	basename: (path, ext) ->
		path = path.replace /^(.*\/)([^\/]*)$/, '$2'
		if ext
			pos = path.length - ext.length
			path = path = path[..pos]  and path[pos..] is ext
		path

	join: (parts...) ->
		abs = parts[0] and fs.isAbsolute parts[0] 
		path = (trim p for p in parts when p).join('/')
		path = "/#{path}" if abs
		path


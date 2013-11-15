{join, dirname} = require('../path')
fs = require 'fs'

module.exports = (dir, options = {}) ->

	(path, box, page) ->
		path = join dir, path

		fs.makeTree dirname path

		page.clipRect = box if box
		
		page.render "#{path}"
		
		delete page.clipRect
		
		@resolve path
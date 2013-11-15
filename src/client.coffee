{dirname, join} = require('./path')

module.exports = (page) ->
	page.injectJs 'vendor/q/q.js'
	page.evaluate ->
		do =>
			deffered = []

			if typeof @callPhantom isnt 'function'
				@callPhantom = ->

			send = ->
				id = window.callPhantom [].slice.apply arguments
				def =  Q.defer()
				if id?
					deffered[id] = def
				else
					def.resolve()

				def.promise


			@phantom =
				send: send
				reject: (id, error) ->
					if deffered[id]
						deffered[id].reject new Error error
						delete deffered[id]
						true
					false

				resolve: (id, args) ->
					if deffered[id]?
						def = deffered[id]
						def.resolve.apply def, args
						delete deffered[id]
						true
					false

				abort: (id) ->
					if deffered[id]
						send 'abort', id
						delete deffered[id]
						true
					false

				exit: (code) ->
					send 'exit', code

				render: (path, selector) ->
					if selector
						el = document.querySelector selector
						bbox = el.getBoundingClientRect() if el?
					send 'render', path, bbox

				resize: (width, height) ->
					send 'resize', width, height

				output: (data) ->
					send 'output', data

				append: (path, data) ->
					send 'append', data
				read: (path, data) ->
					send 'read', data
				write: (path, data) ->
					send 'write', data

				task: (name, options) ->
					send 'task', name, options

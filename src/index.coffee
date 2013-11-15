{spawn} = require('child_process')
Q = require('../vendor/q/q')
webpage = require('webpage')

module.exports.filewriter = require './handlers/filewriter'
module.exports.filereader = require './handlers/filereader'
module.exports.renderer = require './handlers/renderer'

EVENTS = {}
PAGES = []

# Simplistic events handling for all pages
module.exports.on = (name, handler) ->
	EVENTS[name] = handler
	this

module.exports.off = (name) ->
	delete EVENTS[name]
	page.off name for p in PAGES when p
	this

makePage = (page) ->

	page.id = PAGES.length
	PAGES.push page

	# Event definitions local to page for overrides.
	events = {}

	pendingTasks = []

	clearTask = (id) ->
		task = pendingTasks[id]
		if task
			clearTimeout pendingTasks[id].timeout
			# Do our best to kill any spawned tasks
			cp.kill() for cp in task.children
			delete pendingTasks[id]

	queueTask = (method, args) ->
		# children = []
		def = Q.defer()
		
		# In order to handle be able to abort without leaving ghost subprocesses
		# pass this helper to handlers
		cp = spawn arguments...
		children.push cp
		cp
	

		id = pendingTasks.length
		pendingTasks.push
			children: children
			timeout: setTimeout (-> method.apply def, args), 0

		task = def.promise
		task.id = id
		# Return a promise object
		task

	page.on = (name, handler) ->
		events[name] = handler
		page

	page.off = (name) -> 
		delete events[name]
		page

	trigger = (name, args...) ->
		switch name
			# 'core' events
			when 'exit'then phantom.exit()
			when 'close' then page.close()
			# Aborts a requested task.
			when 'abort' then clearTask args[0]
			when 'output' then console.log.apply null, args
			when 'resize' then page.viewportSize =
				width: parseInt args[0], 10
				height: parseInt args[1], 10
			else
				throw new Error "Invalid event name: #{name}." unless events[name] or EVENTS[name]
				
				handler = events[name] or EVENTS[name]

				task = queueTask handler, args.concat page, phantom

				if task?
					task.fail (reason) ->
						# Handler rejected the task
						clearTask task.id
						page.evaluate (id, reason) -> window.phantom.reject arguments...
						, task.id, "#{reason}"

					task.then ->
						clearTask task.id
						page.evaluate (id, args) ->
							window.phantom.resolve id, args
						, task.id, [].slice.apply arguments

					# task.done()

		return null unless task?
		task

	# Be nice and clear all timeouts.
	page.onClosing = ->
		clearTask[i] for task, i in pendingTasks
		return

	# Handle messages from client
	page.onCallback = (data) ->
		throw new Error 'Data must be an array.' unless data instanceof Array
		task = trigger data...
		task?.id


	require('./client') page

	page.onPageCreated = (p) ->

		makePage p
		# Pass on any local event handlers to child pages
		for own name, handler of events
			p.on name = handler

	page


module.exports.page = ->
	page = webpage.create()
	makePage page

_ = require 'lodash'
path = require 'path'
restful = require 'restful'
resourceful = require 'resourceful'
include_all = require 'include-all'


module.exports = (env, done) ->

	defaults =
		router:
			strict: true

	done() unless env.config.restful?

	class RestfulMiddlewarePlugin extends env.MiddlewarePlugin
		routers: []
		constructor: ->
			for group in env.config.restful
				options = _.merge defaults, group or {}
				env.logger.info '[middleware.RESTful]'.blue, options.prefix.green

				resources = []
				modules = include_all
					dirname: path.resolve options.resources
					filter: /(.+)\.[coffee|js]/

				for name, resource of modules
					env.logger.info '[middleware.RESTful]'.blue, options.prefix.green, 'loading resource', name
					resources.push resourceful.define name, resource

				if resources.length
					@routers.push restful.createRouter resources, options

		dispatch: (request, response, next) ->
			super request, response, next
			for router in @routers
				router.dispatch request, response, next


	env.registerMiddlewarePlugin RestfulMiddlewarePlugin

	done()

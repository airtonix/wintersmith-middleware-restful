_ = require 'lodash'
async = require 'async'
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
				module_paths = path.join env.workDir, options.resources
				modules = include_all
					dirname: module_paths
					filter: /(.+)\.[coffee|js]/

				for name, resource of modules
					env.logger.info '[middleware.RESTful]'.blue, options.prefix.green, 'loading resource', name
					resources.push resourceful.define name, resource

				if resources.length
					@routers.push restful.createRouter resources, options

		dispatch: (request, response, next) ->
			async.waterfall @routers.map (router)->
				(previous, next) ->
					router.dispatch request, response, next
			, (err, results) ->
				next()


	env.registerMiddlewarePlugin RestfulMiddlewarePlugin

	done()

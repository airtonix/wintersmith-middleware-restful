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

		constructor: ->
			for group in env.config.restful
				options = _.merge defaults, group or {}
				env.logger.info '[middleware.RESTful]'.blue, options.prefix.green

				resources = []
				for name, resource of @getResources options.resources
					env.logger.info '[middleware.RESTful]'.blue, options.prefix.green, 'loading resource', name
					resources.push resourceful.define name, resource

				if resources.length
					@router = restful.createRouter resources, options

		getResources: (resource_path)->
			resources = include_all
				dirname: path.resolve resource_path
			return resources

		dispatch: (request, response, next) ->
			super request, response, next
			if @router?
				@router.dispatch request, response, next

	env.registerMiddlewarePlugin RestfulMiddlewarePlugin

	done()

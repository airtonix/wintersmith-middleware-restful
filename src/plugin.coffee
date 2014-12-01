_ = require 'lodash
'
path = require 'path'
restful = require 'restful'
resourceful = require 'resourceful'
include_all = require 'include-all'



module.exports = (env, done) ->

	options = env.config.restful
	done('missing restful config') unless options?


	class RestfulMiddlewarePlugin extends env.MiddlewarePlugin

		constructor: ->
			resources = []
			for name, resource of @resources
				env.logger.info '[middleware.RESTful]'.blue, 'loading resource', name
				resources.push resourceful.define name, resource

			@router = restful.createRouter resources, options.router?={}
			return

		@property 'resources', 'getResources'
		getResources: ->
			resource_path = path.resolve options.resources
			resources = include_all
				dirname: resource_path
				filter: /(.+)Resource.*/
			env.logger.info '[middleware.RESTful]'.blue, 'Resources:', resources
			return resources

		dispatch: (request, response, next) ->
			super request, response, next
			@router.dispatch request, response, next

	env.registerMiddlewarePlugin RestfulMiddlewarePlugin

	done()

resourceful = require 'resourceful'

exports.User = ->
	@use 'memory'

	@restful = true
	@timestamps()
	@number 'id'
	@bool 'active', default: false
	@string 'username'
	@string 'email', format: 'email', require: true
	@string 'password'
	@string 'first_name'
	@string 'last_name'



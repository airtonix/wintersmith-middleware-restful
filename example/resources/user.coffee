module.exports = ->
	@use 'memory'

	# Fields
	@bool 'active', default: false

	@string 'first_name'
	@string 'last_name'
	# @string 'username',
	# 	minimum: 8
	# @string 'email',
	# 	format: 'email'
	# @string 'password'

	@timestamps()


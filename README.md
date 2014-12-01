# Wintersmith Middleware Restful

create restful apis for wintersmith preview mode

- uses [restful](https://github.com/flatiron/restful), [resourceful](https://github.com/flatiron/resourceful) from [flatiron](https://github.com/flatiron/flatiron)


## 2014.12.01: Only works with the wintersmith branch [feature/middleware](https://github.com/airtonix/wintersmith/tree/feature/middleware)


## getting started

```
plugins = [
   ...
   'wintersmith-middleware-restful'
   ...
]

...

restful:
	resources: './src/resources'
```

## resources

```

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

```


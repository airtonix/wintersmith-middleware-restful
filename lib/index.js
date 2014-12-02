(function() {
  var include_all, path, resourceful, restful, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('lodash');

  path = require('path');

  restful = require('restful');

  resourceful = require('resourceful');

  include_all = require('include-all');

  module.exports = function(env, done) {
    var RestfulMiddlewarePlugin, defaults;
    defaults = {
      router: {
        strict: true
      }
    };
    if (env.config.restful == null) {
      done();
    }
    RestfulMiddlewarePlugin = (function(_super) {
      __extends(RestfulMiddlewarePlugin, _super);

      RestfulMiddlewarePlugin.prototype.routers = [];

      function RestfulMiddlewarePlugin() {
        var group, modules, name, options, resource, resources, _i, _len, _ref;
        _ref = env.config.restful;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          group = _ref[_i];
          options = _.merge(defaults, group || {});
          resources = [];
          modules = include_all({
            dirname: path.resolve(options.resources),
            filter: /(.+)\.[coffee|js]/
          });
          for (name in modules) {
            resource = modules[name];
            env.logger.info('[middleware.RESTful]'.blue, options.prefix.green, 'loading resource', name);
            resources.push(resourceful.define(name, resource));
          }
          if (resources.length) {
            this.routers.push(restful.createRouter(resources, options));
          }
        }
      }

      RestfulMiddlewarePlugin.prototype.dispatch = function(request, response, next) {
        var router, _i, _len, _ref, _results;
        RestfulMiddlewarePlugin.__super__.dispatch.call(this, request, response, next);
        _ref = this.routers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          router = _ref[_i];
          _results.push(router.dispatch(request, response, next));
        }
        return _results;
      };

      return RestfulMiddlewarePlugin;

    })(env.MiddlewarePlugin);
    env.registerMiddlewarePlugin(RestfulMiddlewarePlugin);
    return done();
  };

}).call(this);

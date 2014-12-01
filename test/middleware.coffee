#!/usr/bin/env coffee
should = require 'should'
wintersmith = require 'wintersmith'
request = require 'request'
cheerio = require 'cheerio'

HOST='localhost'
PROTOCOL='http'
PORT=8000
ROOT_URL="#{PROTOCOL}://#{HOST}:#{PORT}"


describe 'restful middleware', ->

  before (done) ->
    app = wintersmith
      port: PORT
      contents: "./example/contents"
      templates: "./example/templates"
      plugins: [
        "./"
      ]
      restful: [
        prefix: "/api/v1"
        resources: "../example/resources"
      ]
    app.preview done

  describe 'GET /', ->

    it 'homepage', (done)->
      request.get "#{ROOT_URL}/", (error, response, body) ->
        $ = cheerio.load body
        response.statusCode.should.equal 200
        $('html head title').text().should.equal 'homepage'
        $('body h1').text().should.equal 'homepage'
        done()

  describe 'GET /api', ->

    it 'api-routes', (done) ->
      request.get "#{ROOT_URL}/api", (error, response, body) ->
        $ = cheerio.load body
        response.statusCode.should.equal 200
        console.log body
        done()


# vows
#   .describe 'Plugin'
#   .addBatch
#     'wintersmith environment':
#       topic: -> wintersmith './example/config.json'

#       'loaded ok': (env) ->
#         assert.instanceOf env, wintersmith.Environment

#       'contents':
#         topic: (env) -> env.load @callback

#         'loaded ok': (result) ->
#           assert.instanceOf result.contents, wintersmith.ContentTree

#         'has plugin instances': (result) ->
#           assert.instanceOf result.contents['index.md'], wintersmith.ContentPlugin
#           assert.isArray result.contents._.pages
#           assert.lengthOf result.contents._.pages, 1

#         'contains the right text': (result) ->
#           for item in result.contents._.pages
#             assert.isObject item.metadata
#             assert.isString item.metadata.template
#             assert.match item.metadata.template, /^index.jade/

#             assert.isString item.markdown
#             assert.match item.markdown, /^\n\nWintersmith Mounter Plugin/

#   .export module
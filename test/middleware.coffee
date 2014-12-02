#!/usr/bin/env coffee
_ = require 'lodash'
async = require 'async'
should = require('chai').should()
wintersmith = require 'wintersmith/src'
request = require 'request'
cheerio = require 'cheerio'

HOST='localhost'
PROTOCOL='http'
PORT=8000
ROOT_URL="#{PROTOCOL}://#{HOST}:#{PORT}"

app = null
app_server = null


createServer = (done)->
  app = wintersmith './example/config.json', __dirname+'/../example/'
  # shut the logger up.
  app.logger.transports = []
  app.preview (error, server)->
    app.server = server[1]
    done error

destroyServer = (done) ->
  app.server.destroy()
  done()


User =
  id: 1
  first_name: 'john'
  last_name: 'doe'
  username: 'johnnyboy'
  email: 'john@place.net'
  password: 'test123'


describe 'wintersmith-middleware-restful', ->

  ###*
   * Setup Wintersmith Server for tests
  ###
  beforeEach createServer

  afterEach destroyServer


  ###*
   * Test normal wintersmith operations
  ###
  describe 'Normal Templates', ->

    it 'response is 200', (done)->
      request.get "#{ROOT_URL}", (error, response, body) ->
        should.not.exist error
        response.statusCode.should.equal 200
        done()

    it 'title is "homepage"', (done)->
      request.get "#{ROOT_URL}", (error, response, body) ->
        $ = cheerio.load body
        $('html head title').text().should.equal 'homepage'
        done()

    it 'h1 is "homepage"', (done)->
      request.get "#{ROOT_URL}", (error, response, body) ->
        $ = cheerio.load body
        $('body h1').text().should.equal 'homepage'
        done()


  ###*
   * Test our RESTful api middleware
  ###
  describe 'Api Directory Browser', ->

    it 'response is 200', (done) ->
      request.get "#{ROOT_URL}/api/v1", (error, response, body) ->
        response.statusCode.should.equal 200
        done()

    it 'routes lists all verbs', (done) ->
      request.get "#{ROOT_URL}/api/v1", (error, response, body) ->
        $ = cheerio.load body
        body.should.match /GET.*\/api\/v1/
        body.should.match /POST.*\/api\/v1\/user\/new/
        body.should.match /GET.*\/api\/v1\/user\/new/

        body.should.match /GET.*\/api\/v1\/user\/find/
        body.should.match /POST.*\/api\/v1\/user\/find/

        body.should.match /GET.*\/api\/v1\/user\/.*\/update/
        body.should.match /POST.*\/api\/v1\/user\/.*\/update/

        body.should.match /GET.*\/api\/v1\/user\/.*\/destroy/
        body.should.match /POST.*\/api\/v1\/user\/.*\/destroy/

        body.should.match /POST.*\/api\/v1\/user\/.*/
        body.should.match /GET.*\/api\/v1\/user\/.*/
        body.should.match /DELETE.*\/api\/v1\/user\/.*/
        body.should.match /PUT.*\/api\/v1\/user\/.*/

        body.should.match /GET.*\/api\/v1\/user/
        body.should.match /POST.*\/api\/v1\/user/

        done()

  describe '/api/v1/user', ->

    it 'POST new', (done) ->
      request.post "#{ROOT_URL}/api/v1/user/new", User, (error, response, body) ->
        data = JSON.parse response.body
        response.statusCode.should.equal 201
        data.user.id.should.have.length.above 0
        done()

    it 'GET created', (done) ->
      request.post "#{ROOT_URL}/api/v1/user/new", User, (error, response, body) ->
        id = JSON.parse(body).user.id

        request.get "#{ROOT_URL}/api/v1/user/#{id}", (error, response, body) ->
          user = JSON.parse(body).user
          user.id.should.equal id
          done()

    it 'GET all', (done) ->
      range = [7...0]
      tasks = range.map (item)->
        (next) ->
          request.post "#{ROOT_URL}/api/v1/user/new", {}, (error, response, body) ->
            next()

      async.waterfall tasks, (err, results) ->
          request.get "#{ROOT_URL}/api/v1/user", (error, response, body) ->
            data = JSON.parse(body).user
            console.log _.pluck data, 'id'
            # user.should.have.length(8)
            done()

    it 'DELETE id:1', (done) ->
      request.post "#{ROOT_URL}/api/v1/user/1/destroy", (error, response, body) ->
        response.statusCode.should.equal 204
        done()

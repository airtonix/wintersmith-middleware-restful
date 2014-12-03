#!/usr/bin/env coffee
_ = require 'lodash'
async = require 'async'
should = require('chai').should()
wintersmith = require 'wintersmith/src'
request = require 'requestify'
cheerio = require 'cheerio'

restful = require 'restful'
resourceful = require 'resourceful'

UserSchema = require '../example/resources/user'


HOST='localhost'
PROTOCOL='http'
PORT=8000
ROOT_URL="#{PROTOCOL}://#{HOST}:#{PORT}"

app = null
app_server = null


createServer = (done) ->
  app = wintersmith './example/config.json', __dirname+'/../example/'
  # shut the logger up.
  app.logger.transports = []
  app.preview (error, server) ->
    app.server = server[1]
    done error

destroyServer = (done) ->
  app.server.destroy()
  done()


ValidUserData =
  id: 1
  active: true
  first_name: 'john'
  last_name: 'doe'
  username: 'johnnyboy'
  email: 'john@place.net'
  password: 'test123'

InvalidUserSchema =
  email: 'john@123'

InvalidUserData =
 _.merge {}, ValidUserData, InvalidUserSchema


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

    it 'response is 200', (done) ->
      request.get "#{ROOT_URL}"
        .then (response) ->
          response.getCode().should.equal 200
          done()

    it 'title is "homepage"', (done) ->
      request.get "#{ROOT_URL}"
        .then (response) ->
          $ = cheerio.load response.getBody()
          $('html head title').text().should.equal 'homepage'
          done()

    it 'h1 is "homepage"', (done) ->
      request.get "#{ROOT_URL}"
        .then (response) ->
          $ = cheerio.load response.getBody()
          $('body h1').text().should.equal 'homepage'
          done()

  ###*
   * Test the resources
  ###
  describe 'Resources', ->

    it 'valid resourceful object', (done) ->
      UserResource = resourceful.define 'user', UserSchema
      UserResource.create ValidUserData, (err, user) ->
        user.should.contain.keys _.keys ValidUserData
        done()

    it 'rejects invalid data', (done) ->
      UserResource = resourceful.define 'user', UserSchema
      UserResource.create InvalidUserData, (err, user) ->
        err.should.exist()
        err.validate.valid.should.be.equal false
        err.validate.errors.should.have.length _.keys(InvalidUserSchema).length
        done()


  ###*
   * Test our RESTful api middleware
  ###
  describe '/api/v1/', ->

    it 'routes lists all verbs', (done) ->

      request.get "#{ROOT_URL}/api/v1/" #, (err, res, body)->
        .then (response) ->
          body = response.body
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

    it 'GET created', (done) ->
      async.waterfall [
        (next) ->
          request.post "#{ROOT_URL}/api/v1/user", ValidUserData
            .then (response) ->
              user = response.getBody().user
              next(null, user.id)

        (id, next) ->
          request.put "#{ROOT_URL}/api/v1/user/#{id}", ValidUserData
            .then (response) ->
              response.getCode().should.equal 204
              next(null, id)

        (id) ->
          request.get "#{ROOT_URL}/api/v1/user/#{id}"
            .then (response) ->
              user = response.getBody().user
              done()
      ]

    # it 'GET all', (done) ->
    #   tasks = [8...0].map (item) ->
    #     (next) ->
    #       options =
    #         uri: "#{ROOT_URL}/api/v1/user/new"
    #         json: true

    #       request.post options, {}, (error, response, body) ->
    #         user = JSON.parse(body).user
    #         next()

    #   async.waterfall tasks, (err, results) ->
    #     options:
    #       uri: "#{ROOT_URL}/api/v1/user"
    #       json: true

    #     request.get options, (error, response, body) ->
    #       body.should.contain.keys ['user']
    #       body.users.should.have.length(8)
    #       done()

    # it 'DELETE id:1', (done) ->
    #   options =
    #     uri: "#{ROOT_URL}/api/v1/user/1/destroy"
    #     json: true

    #   request.post options, (error, response, body) ->
    #     response.statusCode.should.equal 204
    #     done()

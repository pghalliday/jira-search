jira = require '../../mock/jira'
request = require 'request'
Q = require 'q'
port = 3000
chai = require 'chai'
chai.should()

describe 'jira', ->
  describe 'start/stop', ->
    it 'should reset array of requests', ->
      jira.requests.should.have.length 0
      jira.start(port)
        .then ->
          Q.nfcall(
            request,
            strictSSL: false
            method: 'Get'
            uri: 'https://localhost:' + port
          )
        .then ->
          jira.requests.should.have.length 1
          Q.nfcall(
            request,
            strictSSL: false
            method: 'Get'
            uri: 'https://localhost:' + port
          )
        .then ->
          jira.requests.should.have.length 2
          jira.stop()
        .then ->
          jira.requests.should.have.length 0
  describe 'GET', ->
    beforeEach ->
      jira.start port
    afterEach ->
      jira.stop()
    it 'should record request params', ->
      params =
        strictSSL: false
        method: 'Get'
        uri: 'https://localhost:' + port + '/path'
        auth:
          user: 'user'
          pass: 'pass'
          sendImmediately: true
        qs:
          jql: 'jql'
          maxResults: 0
          startAt: 0
          fields: 'fields'
          expand: true
      Q.nfcall(request, params)
        .spread (response, body) ->
          response.statusCode.should.eql 200
          req = jira.requests[0]
          req.method.should.equal 'GET'
          req.url.should.equal(
            '/path?jql=jql&maxResults=0&startAt=0&fields=fields&expand=true'
          )
          authBuffer = new Buffer(
            req.headers.authorization.substring(6)
            'base64'
          )
          authBuffer.toString('ascii').should.equal 'user:pass'

jira = require '../../mock/jira'
request = require 'superagent'
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
          query = request
            .get 'https://localhost:' + port
          Q.ninvoke(
            query,
            'end'
          )
        .then ->
          jira.requests.should.have.length 1
          query = request
            .get 'https://localhost:' + port
          Q.ninvoke(
            query,
            'end'
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
      console.log 'stop'
      jira.stop()
    it 'should record request params', ->
      query = request
        .get('https://localhost:' + port + '/path')
        .auth('user', 'pass')
        .query
          jql: 'jql'
          maxResults: 0
          startAt: 0
          fields: 'fields'
          expand: true
      Q.ninvoke(query, 'end')
        .then (response) ->
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
    describe 'rejectNextRequest', ->
      it 'should cause the next request to be rejected', ->
        jira.rejectNextRequest()
        query = request
          .get 'https://localhost:' + port
        Q.ninvoke(
          query,
          'end'
        )
          .should.be.rejected
          .then ->
            console.log 'request'
            query = request
              .get 'https://localhost:' + port
            Q.ninvoke(
              query,
              'end'
            )
          .should.be.fulfilled

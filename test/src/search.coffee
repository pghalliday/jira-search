search = require '../../src/search'
jira = require '../../mock/jira'
port = 3000
chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.should()
chai.use chaiAsPromised

describe 'search', ->
  before ->
    jira.start port
  after ->
    jira.stop()
  it 'should pass', ->
    search(
      serverRoot: 'https://localhost:' + port
      strictSSL: false
      user: 'myuser'
      pass: 'mypassword'
      jql: 'project="myproject"'
      fields: '*all'
      expand: 'changelog'
      maxResults: 50
      onTotal: (total) ->
        total.should.equal 1000
      mapCallback: (issue) ->
        issue.id
    )
      .then (issues) ->
        jira.requests.should.have.length 21
        issues.should.deep.equal [1..1000]
  it 'should handle errors on request for total', ->
    jira.rejectNextRequest()
    search(
      serverRoot: 'https://localhost:' + port
      strictSSL: false
      user: 'myuser'
      pass: 'mypassword'
      jql: 'project="myproject"'
      fields: '*all'
      expand: 'changelog'
      maxResults: 50
    )
      .should.be.rejected
  it 'should handle errors on request for issues', ->
    search(
      serverRoot: 'https://localhost:' + port
      strictSSL: false
      user: 'myuser'
      pass: 'mypassword'
      jql: 'project="myproject"'
      fields: '*all'
      expand: 'changelog'
      maxResults: 50
      onTotal: ->
        jira.rejectNextRequest()
    )
      .should.be.rejected

search = require '../../src/search'
jira = require '../../mock/jira'
port = 3000
chai = require 'chai'
chai.should()

describe 'search', ->
  before ->
    jira.start port
  after ->
    jira.stop()
  it 'should pass', ->
    issues = []
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
        console.log issue
        issues.push issue
    )
      .then ->
        jira.requests.should.have.length 21
        issues.should.have.length 1000

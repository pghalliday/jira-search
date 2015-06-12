fs = require 'fs'
Q = require 'q'
https = require 'https'
url = require 'url'

total = 1000
result =
  expand: ''
  startAt: 0
  maxResults: 0
  total: total
  issues: []

jira =
  start: (port) ->
    Q.ninvoke server, 'listen', port
  stop: ->
    Q.ninvoke server, 'close'
    jira.requests = []
  requests: []

options =
  key: fs.readFileSync 'test/certs/server.key'
  cert: fs.readFileSync 'test/certs/server.crt'
  passphrase: 'passphrase'
server = https.createServer options, (request, response) ->
  jira.requests.push request
  query = url.parse(request.url, true).query
  startAt = parseInt query.startAt
  maxResults = parseInt query.maxResults
  result.expand = query.expand
  result.startAt = startAt
  result.maxResults = maxResults
  startId = startAt + 1
  endId = Math.min(startAt + maxResults, total)
  result.issues = for id in [startId..endId]
    expand: ''
    id: id
    key: 'KEY-' + id
  response.writeHead 200,
    'Content-Type': 'application/json'
  response.end JSON.stringify(result)
module.exports = jira

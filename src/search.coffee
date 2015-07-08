request = require 'superagent'
Q = require 'q'

module.exports = (params) ->
  params.onTotal = params.onTotal || ->
  params.mapCallback = params.mapCallback || (issue) -> issue
  searchRequest = (startAt, maxResults, fields, expand) ->
    query = request
      .get(params.serverRoot + '/rest/api/2/search')
      .query
        jql: params.jql
        maxResults: maxResults
        startAt: startAt
        fields: fields
        expand: expand
    if params.user
      query.auth params.user, params.pass
    query

  Q()
    .then ->
      query = searchRequest 0, 0, '', ''
      deferred = Q.defer()
      query.end (error, response) ->
        if error
          deferred.reject error
        else
          deferred.resolve response.body.total
      deferred.promise
    .then (total) ->
      params.onTotal total
      remaining = total
      issuesPromise = (start, array) ->
        deferred = Q.defer()
        query = searchRequest(
          start
          params.maxResults
          params.fields
          params.expand
        )
        query.end (error, response) ->
          if error
            deferred.reject error
          else
            issues = (
              params.mapCallback(issue) for issue in response.body.issues
            )
            deferred.resolve array.concat issues
        deferred.promise
      issuesPromiseCalls = while remaining > 0
        start = total - remaining
        remaining -= params.maxResults
        issuesPromise.bind null, start
      issuesPromiseCalls.reduce((soFar, f) ->
        soFar.then(f)
      , Q([]))

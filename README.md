jira-search
===========

[![Build Status](https://travis-ci.org/pghalliday/jira-search.svg?branch=master)](https://travis-ci.org/pghalliday/jira-search)

Promise based NodeJS library to perform JIRA searches, optimised for large result sets

Usage
-----

```
npm install jira-search
```

```javascript
var search = require('jira-search');

search({
  serverRoot: 'https://my.jira.server', // the base URL for the JIRA server
  user: 'myuser', // the user name
  pass: 'mypassword', // the password
  jql: 'project="myproject"', // the JQL
  fields: '*all', // the fields parameter for the JIRA search
  expand: 'changelog', // the expand parameter for the JIRA search
  maxResults: 50, // the maximum number of results for each request to JIRA, multiple requests will be made till all the matching issues have been collected
  onTotal: function (total) {
    // optionally initialise a progress bar or something
  },
  mapCallback: function (issue) {
    // This will be called for each issue matching the search.
    // Update a progress bar or something if you want here.
    // The return value from this function will be added
    // to the array returned by the promise.
    // If omitted the default behaviour is to add the whole issue
    return issue.key;
  }
}).then(function (issues) {
  // consume the collected issues array here
}).done();
```

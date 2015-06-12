#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TMP_DIR=`mktemp -d` && cd $TMP_DIR
npm install $DIR
node -e "var assert = require('assert'); var search = require('jira-search'); assert.equal(typeof search, 'function');"
rm -rf $TMP_DIR

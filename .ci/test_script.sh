#!/bin/bash

set -e

# Script requires GITHUB_TOKEN env variable
MENTIONED_ISSUES=/tmp/mentioned_issues
CLOSED_ISSUES=/tmp/failed_issues
LINKED_ISSUES_FORMATTED=/tmp/linked_issues

# Linked issues that are mentioned in the code
LINKED_ISSUES_MENTIONED=/tmp/linked_issues_mentioned
API_GITHUB_PREFIX="https://api.github.com/repos"
GITHUB_HOST="https://github.com"
CHECKSTYLE_ISSUE_PREFIX="https:\/\/github.com\/Vyom-Yadav\/actions-test\/issues\/"
REPO="Vyom-Yadav/actions-test"
BRANCH="master"

cat /dev/null > $MENTIONED_ISSUES

# collect issues where full link is used
grep -IPonr "(after|[Tt]il[l]?) $GITHUB_HOST/[\w.-]+/[\w.-]+/issues/\d{1,5}" . \
  | perl -pe 's/:(?!\d).*github.com\//:/' >> $MENTIONED_ISSUES

for line in $(sort -u $MENTIONED_ISSUES); do
  location=${line%:[0-9]*}
  location=${location:2}
  line_number=${line#*:}
  line_number=${line_number%:*}
  LINK="$GITHUB_HOST/$REPO/blob/$BRANCH/$location#L$line_number"
  echo $LINK
done

cat $MENTIONED_ISSUES
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
MAIN_REPO="Vyom-Yadav/actions-test"
DEFAULT_BRANCH="master"

if [ ! -z "$PR_HEAD_REPO_NAME" ]; then
  MAIN_REPO=$PR_HEAD_REPO_NAME
  DEFAULT_BRANCH=$GITHUB_HEAD_REF
fi

# collect issues where full link is used
grep -IPonr "(after|[Tt]il[l]?) $GITHUB_HOST/[\w.-]+/[\w.-]+/issues/\d{1,5}" . \
  | perl -pe 's/:(?!\d).*github.com\//:/' >> $MENTIONED_ISSUES

# collect checkstyle issues where only hash sign is used
grep -IPonr "[Tt]il[l]? #\d{1,5}" . \
  | perl -pe 's/:(?!\d).*#/:Vyom-Yadav\/actions-test\/issues\//' >> $MENTIONED_ISSUES

# $LINKED_ISSUES need formatting before the are used
if [ ! -z "$LINKED_ISSUES" ]; then
  echo $LINKED_ISSUES | sed -e 's/,/\n/g' >> $LINKED_ISSUES_FORMATTED
  sed -i "s/^/$CHECKSTYLE_ISSUE_PREFIX/g" $LINKED_ISSUES_FORMATTED
fi

for line in $(sort -u $MENTIONED_ISSUES); do
  issue=${line#*[0-9]:}
  location=${line%:[0-9]*}
  location=${location:2}
  line_number=${line#*:}
  line_number=${line_number%:*}
  LINK="$GITHUB_HOST/$MAIN_REPO/blob/$DEFAULT_BRANCH/$location#L$line_number"
  STATE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$API_GITHUB_PREFIX/$issue" \
   | jq '.state' | xargs)
  if [ "$STATE" = "closed" ]; then
    echo "$LINK" >> $CLOSED_ISSUES
  elif [ ! -z "$LINKED_ISSUES" ]; then
    for linked_issue in $(sort -u $LINKED_ISSUES_FORMATTED); do
      if [ "$linked_issue" = "$GITHUB_HOST/$issue" ]; then
        echo "$LINK" >> $LINKED_ISSUES_MENTIONED
      fi
    done
  fi
done

if [ -f "$CLOSED_ISSUES" ]; then
    printf "\nFollowing issues are mentioned in code to do something after they are closed:\n\n"
    cat $CLOSED_ISSUES
    if [ -f "$LINKED_ISSUES_MENTIONED" ]; then
      printf "\nFollowing issues are linked to the pull request and are also mentioned in the code:\n\n"
      cat $LINKED_ISSUES_MENTIONED
    fi
    exit 1
fi

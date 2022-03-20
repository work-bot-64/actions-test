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

echo "Linked issues are:- "$LINKED_ISSUES

# collect issues where full link is used
grep -IPor "(after|[Tt]il[l]?) $GITHUB_HOST/[\w.-]+/[\w.-]+/issues/\d{1,5}" . \
  | sed -e 's/:.*github.com\//:/' >> $MENTIONED_ISSUES

# collect checkstyle issues where only hash sign is used
grep -IPor "[Tt]il[l]? #\d{1,5}" . \
  | sed -e 's/:.*#/:Vyom-Yadav\/actions-test\/issues\//' >> $MENTIONED_ISSUES

# $LINKED_ISSUES need formatting before the are used
if [ ! -z "$LINKED_ISSUES" ]; then
  echo $LINKED_ISSUES | sed -e 's/, /\n/g' >> $LINKED_ISSUES_FORMATTED
  sed -i "s/^/$CHECKSTYLE_ISSUE_PREFIX/g" $LINKED_ISSUES_FORMATTED
fi

echo "Formatted linked issues are:- "$LINKED_ISSUES_FORMATTED

for line in $(sort -u $MENTIONED_ISSUES); do
  issue=${line#*:}
  STATE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$API_GITHUB_PREFIX/$issue" \
   | jq '.state' | xargs)
  if [ "$STATE" = "closed" ]; then
    echo "${line%:*} -> $GITHUB_HOST/$issue" >> $CLOSED_ISSUES
  elif [ ! -z "$LINKED_ISSUES" ]; then
    for linked_issue in $(sort -u $LINKED_ISSUES_FORMATTED); do
      if [ "$linked_issue" = "$GITHUB_HOST/$issue" ]; then
        echo "${line%:*} -> $GITHUB_HOST/$issue" >> $LINKED_ISSUES_MENTIONED
      fi
    done
  fi
done

if [ -f "$CLOSED_ISSUES" ]; then
    echo "Following issues are mentioned in code to do something after they are closed:"
    cat $CLOSED_ISSUES
    if [ -f "$LINKED_ISSUES_MENTIONED" ]; then
      echo "Following issues are linked to the pull request and are also mentioned in the code:"
      cat $LINKED_ISSUES_MENTIONED
    fi
    exit 1
fi
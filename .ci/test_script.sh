#!/bin/bash

set -e
LINKED_ISSUES_FORMATTED=/tmp/linked_issues
cat /dev/null > $LINKED_ISSUES_FORMATTED
LINKED_ISSUES="37,38,39"
CHECKSTYLE_ISSUE_PREFIX="https:\/\/github.com\/Vyom-Yadav\/actions-test\/issues\/"
if [ ! -z "$LINKED_ISSUES" ]; then
  echo $LINKED_ISSUES | sed -e 's/,/\n/g' >> $LINKED_ISSUES_FORMATTED
  sed -i "s/^/$CHECKSTYLE_ISSUE_PREFIX/g" $LINKED_ISSUES_FORMATTED
fi
cat $LINKED_ISSUES_FORMATTED
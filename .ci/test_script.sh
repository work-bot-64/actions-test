#!/bin/bash

set -e
cat /dev/null > /tmp/linked_issues
GITHUB_HOST="https:\/\/github.com\/checkstyle\/checkstyle\/issues\/"
FOO="foo"
LINKED_ISSUES="37, 38"
if [ ! -z "$LINKED_ISSUES" ]; then
echo $LINKED_ISSUES | sed -e 's/, /\n/g' >> /tmp/linked_issues
sed -i "s/^/$GITHUB_HOST/g" /tmp/linked_issues
fi
cat /tmp/linked_issues
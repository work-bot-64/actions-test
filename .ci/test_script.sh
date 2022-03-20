#!/bin/bash

set -e
cat /dev/null > /tmp/linked_issues
LINKED_ISSUES="https://github.com/foo/bar/issues/1 https://github.com/foo/bar/issues/2 https://github.com/foo/bar/issues/3"
echo $LINKED_ISSUES | sed -e 's/ /\n/g' >> /tmp/linked_issues
cat /tmp/linked_issues
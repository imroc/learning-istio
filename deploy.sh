#! /bin/bash

set -eux 

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

msg="rebuilding site `date`"
if [ $# -eq 1  ]
    then msg="$1"
fi

# Build the project. 
hugo -d docs

# Add changes to git.
git add .

# Commit changes.

git commit -m "$msg"

# Push source and build repos.
git push origin master
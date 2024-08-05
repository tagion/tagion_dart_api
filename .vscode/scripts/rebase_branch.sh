read -p "Enter the name of the branch to rebase onto main: " branchName
git checkout main
git pull
git rebase main  "$branchName"
git push origin "$branchName" --force

# case: 
# local main is behind remote main, so that we can check that the pull and checkout work properly
# the target branch exists on remote, so that we can check that after the task the remote branch is also rebased onto main
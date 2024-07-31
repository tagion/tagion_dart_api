read -p "Enter the name of the branch to rebase onto main: " branchName
git pull
git checkout main
git rebase main  "$branchName"
# git push --force
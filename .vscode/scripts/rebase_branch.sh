read -p "Enter the name of the branch to rebase onto main: " branchName
git checkout main
git pull
git rebase main  "$branchName"
git push --force
git pull
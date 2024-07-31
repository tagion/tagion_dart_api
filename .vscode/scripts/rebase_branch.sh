read -p "Enter the name of the branch to rebase onto main: " branchName
git pull
git checkout origin/main
git rebase main  "$branchName"
git push --force
git pull
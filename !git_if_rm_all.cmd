echo RESET GITHUB?
pause
git init
git remote add origin https://github.com/kujik/uchet.git
git branch -M main
git add .
git commit -m "Initial commit"
git push --set-upstream origin main --force

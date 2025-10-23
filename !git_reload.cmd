echo ======================Reload ALL???
pause
echo Reload ALL???
pause
git reset --hard HEAD
git clean -fd
git fetch origin
git reset --hard origin/main

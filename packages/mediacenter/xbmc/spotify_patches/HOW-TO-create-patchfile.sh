#!/bin/sh

echo Please wait..
echo

#If not done before, clone the official XBMC source to local repository
if [ -e /$HOME/patchcreate_xbmc_source ]
then
  # This script have been run before, we only need to pull the latest xbmc source code from repository.
  cd $HOME/patchcreate_xbmc_source
  git pull
else
  # First time we run this script, we need to clone the complete xbmc source code repository.
  git clone git://github.com/xbmc/xbmc.git $HOME/patchcreate_xbmc_source
  cd $HOME/patchcreate_xbmc_source

  # Add spotyxbmc2 remote repository to our local repository:
  git remote add spotyxbmc2 git://github.com/akezeke/spotyxbmc2.git
fi

# Update with the latest source code from the remote spotyxbmc2 repository.
git fetch spotyxbmc2

# Create a branch with the latest spotyxbmc2 source code.
git checkout --track -b spotyxbmc2 spotyxbmc2/master

# Need to remember the last commit in spotyxbmc2 source for our patch filename.
SPOTYXBMC2_LAST_COMMIT=$(git log | head -n 1 | cut -c 8-17)

# Create a branch at the last xbmc commit that is also included in spotyxbmc2 fork.
git checkout -b last_common $(git merge-base master spotyxbmc2)

# We need a temporary branch that we will use for the spotyxbmc2 patch creation.
git checkout -b tmpsquash

# Merge all changes done in the spotyxbmc source code to our temporary branch.
git merge --squash spotyxbmc2

# Commit our merge. The message text here will become our patch filename later.
git commit -a -m "spotyxbmc2-$SPOTYXBMC2_LAST_COMMIT-Spotify-support-for-xbmc"

# Create our patch (we are excluding any changes made to confluence skin):
git format-patch --unified=3 last_common -- $(git ls-files | grep -v -e skin.confluence -e project)

# As a sidenote, the only spoyxbmc2 change in the skin is addition of a audio flagging icon.
# When compiling, this icon image will be copied by the openelec skin install script.

cd -
mv $HOME/patchcreate_xbmc_source/00*.patch .

# Cleanup, here we prepare so we can run this script again.
cd $HOME/patchcreate_xbmc_source
git checkout master
git branch -D spotyxbmc2 tmpsquash last_common
cd -

echo
echo =============================================================================
echo
echo Script is now finished. Please look for your patchfile in this directory:
pwd
echo
echo A repository that includes the last official xbmc source code was created in:
echo $HOME/patchcreate_xbmc_source
echo You might want to delete the above directory to save some disk space.
echo If you keep the folder untouched, it will greatly reduce the time and effort
echo to run this script again some other day in the future.
echo =============================================================================

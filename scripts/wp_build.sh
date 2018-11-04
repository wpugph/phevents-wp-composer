#!/bin/bash
# When PHPCS pass, this will build your composer assets for wp core and plugins and deploy it to Pantheon, you can skip this part if there are no changes in plugins and core
set -ex

export BUILDMSG="GitLab WP build:$CI_COMMIT_MESSAGE"
export ENV=dev

terminus auth:login --machine-token=$MACHINETOKEN --email=$EMAIL
terminus connection:set $PANTHEONSITENAME.dev sftp

#transfer to Pantheon all root related files
rsync -Lvz --ipv4 -a --delete --progress -e 'ssh -p 2222' ./. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/ --exclude *.git* --exclude scripts/ --exclude vendor/

#transfer to Pantheon all necessary vendor folders for WP to work
rsync -Lvz --size-only --ipv4 -a --delete --progress -e 'ssh -p 2222' ./vendor/. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/vendor/ --exclude="*.git*"
rsync -rLvz --size-only --ipv4 --progress -e 'ssh -p 2222' ./vendor/composer/. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/vendor/composer/ --exclude="*.git*"
rsync -rLvz --size-only --ipv4 --progress -e 'ssh -p 2222' ./vendor/johnpbloch/. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/vendor/johnpbloch/ --exclude="*.git*"

#transfer to Pantheon all files and folders in the web folder
rsync -Lvz --size-only --ipv4 -a --delete --progress -e 'ssh -p 2222' ./web/. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/web/ --exclude="*.git*"
rsync -rLvz --size-only --ipv4 --progress -e 'ssh -p 2222' ./web/. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/web/ --exclude="*.git*"

#make sure the modified gitignore is added in Pantheon
rsync -Lvz --size-only --ipv4 --progress -e 'ssh -p 2222' ./.gitignore --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/ --exclude node_modules/ --exclude gulp/ --exclude source/

#Commit in dev environment
terminus env:commit --message "$BUILDMSG" --force -- $PANTHEONSITENAME.$ENV
#terminus env:deploy --note "GitLab:$BUILDMSG" -- $PANTHEONSITENAME.test

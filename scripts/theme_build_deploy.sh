#!/bin/bash
# When PHPCS passes uncompiled, this process will compile your custom theme/plugin then compile them and push the compiled assets only to Pantheon, don't forget to update this file with your theme's/plugin's correct path

# TODO: minification process to clean assets
set -ex

ROOTPWD=`pwd`
cd $ROOTPWD
# wget -qO- https://deb.nodesource.com/setup_10.x | apt-get install -y nodejs #E: Unable to locate package nodejs
# apt-get update #ok
# wget -qO- https://deb.nodesource.com/setup_10.x | bash - #ok
# apt-get install -y nodejs #ok

echo "This is where wp theme assets are built and deployed"
export THEMEBUILDMSG="GitLab WP theme build:$CI_COMMIT_MESSAGE"
export ENV=dev
export WPTHEME=web/wp-content/themes/twentyseventeen-child
#export WPTHEME=web/wp-content/themes/bootstrapfast-child
export THEMEDEPLOYMSG="GitLab Theme deploy:$CI_COMMIT_MESSAGE"
export THEMEEXCLUDE="node_modules/ gulp/ source/"
export THEMEEXCLUDEFILES="*.json"

cd $ROOTPWD/$WPTHEME

npm install -g npm@latest
npm install -g gulp
npm install
npm run gulp
ls

cd $ROOTPWD
terminus auth:login --machine-token=$MACHINETOKEN --email=$EMAIL
terminus connection:set $PANTHEONSITENAME.dev sftp

# sync bootstrapfast child theme
#rsync -rLvz --size-only --ipv4 --progress -e 'ssh -p 2222' ./$WPTHEME/. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/$WPTHEME/ --exclude='*.git*' --exclude node_modules/ --exclude gulp/ --exclude src/

# sync twentyseventeen child theme
rsync -rLvz --size-only --ipv4 --progress -e 'ssh -p 2222' ./$WPTHEME/. --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/$WPTHEME/ --exclude='*.git*' --exclude node_modules/ --exclude gulp/ --exclude source/

#make sure the modified gitignore is added in Pantheon
rsync -Lvz --size-only --ipv4 --progress -e 'ssh -p 2222' ./.gitignore --temp-dir=~/tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:code/ --exclude node_modules/ --exclude gulp/ --exclude source/

terminus env:commit --message "$THEMEBUILDMSG" --force -- $PANTHEONSITENAME.$ENV
terminus env:deploy --note "$THEMEBUILDMSG" -- $PANTHEONSITENAME.test

#terminus env:deploy --note "GitLab:$BUILDMSG" -- $PANTHEONSITENAME.test

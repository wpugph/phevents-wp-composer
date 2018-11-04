#!/bin/bash

# Exit immediately on errors, and echo commands as they are executed.
set -ex

# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" #ok
# php composer-setup.php #ok
# php -r "unlink('composer-setup.php');" #ok
ROOTPWD=`pwd`
touch /root/.ssh/idrsa
echo "$STAGING_PRIVATE_KEY" > /root/.ssh/idrsa
chmod 400 /root/.ssh/idrsa
ssh-add /root/.ssh/idrsa
ssh-add -l
cd $ROOTPWD
#php composer.phar install
composer install
#composer update
# composer global require consolidation/cgr #ok
# cgr --stability RC pantheon-systems/terminus #ok

cat .gitignore | awk '/# :::::::::::::::::::::: cut ::::::::::::::::::::::/ { p=1; next } p' .gitignore > .gitignore2
cp .gitignore2 .gitignore
rm .gitignore2

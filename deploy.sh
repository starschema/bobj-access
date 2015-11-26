#!/bin/bash

if [ "Xjenkins-starschema" == "X$CI_COMMITTER_USERNAME" ]; then echo "Modification by build server, no need to deploy"; exit 0; fi

if [ "X" == "X$GITHUB_USER" ]; then echo "Need GITHUB_USER environment variable"; exit 10; fi
if [ "X" == "X$GITHUB_TOKEN" ]; then echo "Need GITHUB_TOKEN environment variable"; exit 10; fi
if [ "X" == "X$GITHUB_EMAIL" ]; then echo "Need GITHUB_EMAIL environment variable"; exit 10; fi
if [ "X" == "X$HOME" ]; then echo "Need HOME environment variable"; exit 10; fi
if [ "X" == "X$NPM_TOKEN" ]; then echo "Need NPM_TOKEN environment variable"; exit 10; fi

echo "Installing all dependencies..."
npm install
if [ $? -ne 0 ]; then echo "installing dependencies failed"; exit 10; fi

echo "Building..."
node_modules/gulp/bin/gulp.js build
if [ $? -ne 0 ]; then echo "building package failed"; exit 10; fi

echo Set npm user
echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> $HOME/.npmrc
echo "npm user:" `npm whoami`
if [ $? -ne 0 ]; then echo "npm authentication problem"; exit 10; fi

echo "Set github user"
git --version
git config --global push.default simple
git config --global user.name $GITHUB_USER
git config --global user.email $GITHUB_EMAIL

echo "Deploying..."

echo "npm new version " `npm version patch -m "Version %s [ci skip][skip ci]"`
if [ $? -ne 0 ]; then echo "couldn't create new npm package"; exit 10; fi

npm publish
if [ $? -ne 0 ]; then echo "couldn't publish npm package"; exit 10; fi

git push --force "https://$GITHUB_TOKEN@github.com/starschema/$PACKAGE.git" HEAD:master
if [ $? -ne 0 ]; then echo "couldn't push new version to github"; exit 10; fi

#!/bin/bash

npm install
if [ $? -ne 0 ]; then echo "npm install failed"; exit 10; fi
npm test
if [ $? -ne 0 ]; then echo "npm test failed"; exit 10; fi
node_modules/gulp/bin/gulp.js build
if [ $? -ne 0 ]; then echo "gulp build failed"; exit 10; fi

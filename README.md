# less2sass

[![Gem Version](https://badge.fury.io/rb/less_to_sass.svg)](http://badge.fury.io/rb/less_to_sass)
[![Build Status](https://travis-ci.org/vecerek/less2sass.svg)](https://travis-ci.org/vecerek/less2sass)

LESS and SASS are two dynamic style sheet languages with some minor differences in syntax and huge differences in their semantics. The goal of this project is to create a converter application between these formats.

There are some converters available on the Internet, but all of them are working on the search and replace principle and can not produce 100% correct conversion. Less2sass is an AST-based converter, which heavily uses the Less.js and Sass engines in order to correctly parse Less code and generate Sass or SCSS stylesheets, respectively.

## Installing

1. Install *Node.js* v6, if possible, according to the [official instructions](https://nodejs.org/en/download/package-manager/).
   - On Debian (Ubunu/Mint) set an alias in ~/.bashrc file for nodejs.

      ```
      alias node='nodejs'
      ```
2. Set the ```NODE_PATH``` environment variable to store the install location of nodejs in your bash profile. Usually, it is the folder /usr/lib/node_modules.
   
   ```
   export NODE_PATH=/usr/lib/node_modules:$NODE_PATH
   ```
3. Install *Less.js* using the Node.js package manager.

   ```
   $ sudo npm install -g less@2.7.1
   ```
4. You can check, if Less.js has been installed successfully by entering the interactive node shell and trying to require it.    The require should return the path to the module's index file. Usually ```/usr/lib/node_modules/less/index.js```.

   ```
   $ node
   > require.resolve('less')
   ```
5. Install Less2Sass. Note that the name of the gem is less_to_sass, since the alternative with the number was already taken.

   ```ruby
   $ gem install less_to_sass
   ```

## Usage
```
$ less2sass <INPUT> [OUTPUT] [options]
```
Even though the name of the gem is less_to_sass, the executable is used according to the repo's name.

## Development

1. Install Bundler.

   ```ruby
   $ gem install bundler
   ```
2. Clone git repo and enter it.

   ```
   $ git clone https://github.com/vecerek/less2sass
   $ cd less2sass
   ```
3. Install development dependencies using bundler.

   ```
   $ bundle install
   ```
4. Run the tests and enjoy the development!

   ```
   $ bundle exec rspec spec/compare_spec.rb
   ```

## Language differences

There is an entire [wiki page] (https://github.com/vecerek/less2sass/wiki/Language-Differences), that deals with the language differences. It will be continuously updated as new releases of Less and Sass will be published.
The current version of the document describes the differences between Less v2.7.1 and Sass v3.4.21

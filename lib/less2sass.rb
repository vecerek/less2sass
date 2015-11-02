dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'less2sass/constants'
require 'less2sass/error'
require 'less2sass/exec'
require 'less2sass/util'
require 'less2sass/sass'
require 'less2sass/less'

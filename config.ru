#\ -s puma

Bundler.require
require './app'
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

use Rack::ShowExceptions if ENV['RACK_ENV'] == 'development'
run App

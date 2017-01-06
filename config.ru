# This file is used by Rack-based servers to start the application.

$:.unshit File.expand_path('../', __FILE__)
require 'rubygems'
require 'sinatra'
require './server'
run Sinatra::Application

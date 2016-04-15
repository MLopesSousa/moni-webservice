#!/usr/local/bin/ruby

require 'rubygems'
require 'daemons'

bin = File.join(File.expand_path(File.dirname(__FILE__)), 'service/index.rb')

Daemons.run_proc('') do
  loop do
        exec "ruby #{bin}"
  end
end


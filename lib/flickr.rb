require 'rubygems'
require 'xml_magic'
require 'open-uri'
include CommonThread::XML

Dir[File.join(File.dirname(__FILE__), 'flickr/**/*.rb')].sort.each { |lib| require lib }
require "qbxml/version"

require 'nokogiri'
require 'active_support/builder'
require 'active_support/inflections'
require 'active_support/core_ext/string'

class Qbxml; end

require_relative 'qbxml/types.rb'
require_relative 'qbxml/qbxml.rb'
require_relative 'qbxml/hash.rb'

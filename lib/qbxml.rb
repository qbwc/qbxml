require "qbxml/version"

require 'nokogiri'
require 'active_support/builder'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/blank'

class Qbxml; end

require_relative 'qbxml/types.rb'
require_relative 'qbxml/qbxml.rb'
require_relative 'qbxml/hash.rb'

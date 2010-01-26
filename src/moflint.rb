#
# moflint.rb
#
# MOF syntax checker
#  and Mofparser tester
#
require 'pathname'
require File.dirname(__FILE__) + "/../parser/mofparser"

moffiles, options = Mofparser.argv_handler "moflint", ARGV
options[:style] ||= :cim;
options[:includes] ||= []
options[:includes].unshift(Pathname.new ".")

parser = Mofparser.new moffiles, options

begin
  result = parser.parse
rescue Exception => e
  parser.error_handler e
  exit 1
end

# create MediaWiki CIM package page
#
# Usage: [ -p <prefix> ] [ -b <basedir> ] <package>
#
# prefix: Wiki prefix, defaults to SystemsManagement/CIM/Providers
# basedir: schema base directory, defaults to /usr/share/mof/cim-current
#
#

arg = ARGV.shift
basedir = "/usr/share/mof/cim-current"
package = nil
if arg == "-b"
  basedir = ARGV.shift
else
  package = arg
end

prefix = "SystemsManagement/CIM/Providers"

if package.nil?
  $stderr.puts "Usage: [ -b <basedir> ] <package>"
  exit 1
end

content = %x{ "rpm" "-ql" "#{package}" }

unless $?.exitstatus == 0
  $stderr.puts "Package #{package} is not installed"
  exit 1
end

puts "= #{package} ="

content.each do |l|
  next unless l =~ /.mof$/
  next if l =~ /deploy.mof/
  dirs = l.split "/"
  file = dirs.pop
  parent = dirs.pop
  %x{ "ruby" "mofmediawiki.rb" "-I" "/usr/share/mof/cim-current" "-I" "#{dirs.join('/')}" "qualifiers.mof" "qualifiers_optional.mof" "#{parent}/#{file}" }
end


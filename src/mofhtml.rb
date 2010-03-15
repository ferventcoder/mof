#
# mofhtml.rb
#
# MOF to HTML converter
#

require "rexml/document"
require 'pathname'
require 'fileutils'
require File.dirname(__FILE__) + "/../parser/mofparser"

module CIM
  module Schema
    
    class Qualifier
      def self.array_to_html qualifiers, div
	return unless qualifiers
	return if qualifiers.empty?
	container = div.add_element "tr", "class" => "qualifiers_container"
	left = container.add_element "td", "class" => "qualifiers_container_left"
	left.text = "Qualifiers"
	right = container.add_element "td", "class" => "qualifiers_container_right"
	# Qualifiers
	maxlen = 0
	qualifiers.each do |q|
	  s = q.definition.name.size
	  maxlen = s if maxlen < s
	end
	qualifiers.each do |q|
	  q.to_html right, maxlen
	end
      end

      def to_html div, width = 0
	cols = 1
	width = @definition.name.size if width == 0
	name = div.add_element "div", "class" => "qualifier_name"
	name.text = @definition.name.capitalize
	if @value
	  cols += 1
	  data = div.add_element "div", "class" => "qualifier_value"
	  case @value
	  when String
	    @value.split("\\n").each do |l|
	      divc = data.add_element "div", "style" => "clear : both"
	      divc.text = l.gsub "\\\"", '"'
	    end
	  else
	    data.text = @value
	  end
	end
	if @flavor
	  cols += 1
	  data = div.add_element "div", "class" => "qualifier_flavor"
	  data.text = @flavor.to_s
	end
	cols
      end
    end
    
    class Property
      def to_html div
	Qualifier.array_to_html @qualifiers, div
	row = div.add_element "tr", "class" => "property"
	data = row.add_element "td", "class" => "property_data"
	span = data.add_element "td", "class" => "property_type"
	span.text = @type.to_s
	span = data.add_element "td", "class" => "property_name"
	span.text = @name
	if @default
	  span = data.add_element "td", "class" => "property_default"
	  span.text = " = #{@default}"
	end
      end
    end
    
    class Class
      def to_html body
	h1 = body.add_element "h1"
	h1.text = name
	
	table = body.add_element "table", "class" => "class_container", "border" => "1"
	
	tr = table.add_element "tr"
	td = tr.add_element "td", "class" => "class_name"
	td.text = name
	if @alias_name
	  td = tr.add_element "td", "class" => "class_alias"
	  td.text = " as #{@alias_name}"
	end
	if @superclass
	  td = tr.add_element "td", "class" => "parent_name"
	  td.text = ": " 
	  href = td.add_element "a", "href" => "#{@superclass}.html"
	  href.text = @superclass
	end
	
	qcols = Qualifier.array_to_html @qualifiers, table.add_element("table", "border" => "1")
#	return
	
	# Class features
	
	first = true
	@features.each do |f|
	  f.to_html table.add_element "table", "border" => "1"
	end if @features
      end
    end
  end
end

#
# return XHTML tree for class 'c'
#

def class2html c
  name = c.name
  doc = REXML::Document.new
  html = doc.add_element "html", "xmlns"=>"http://www.w3.org/1999/xhtml", "xml:lang"=>"en", "lang"=>"en"
  head = html.add_element "head"
  head.add_element "meta", "http-equiv"=>"Content-type", "content"=>"text/html; charset=utf-8"
  title = head.add_element "title"
  title.text = "Class #{name}"
  css = head.add_element "link", "rel"=>"stylesheet", "href"=>"mofhtml.css", "type"=>"text/css", "media"=>"screen,projection,print"
  body = html.add_element "body"
  c.to_html body
  doc
end

#------------------------------------------------------------------

moffiles, options = Mofparser.argv_handler "mofhtml", ARGV
options[:style] ||= :cim;
options[:includes] ||= []
options[:includes].unshift(Pathname.new ".")

parser = Mofparser.new options

begin
  result = parser.parse moffiles
rescue Exception => e
  parser.error_handler e
  exit 1
end

exit 0 unless result

basedir = File.join("html", options[:namespace])

result.each do |name, res|
  res.classes.each do |c|
    xhtml = class2html c
    dir = "#{basedir}/class"
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    xhtml.write( File.new("#{dir}/#{c.name}.html", "w+"), 0 )
  end
end

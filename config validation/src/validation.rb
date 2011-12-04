##!/usr/bin/env ruby

begin
  require 'rubygems'
rescue LoadError
  $stderr.puts "#{$0} requires installed rubygems\n"
  exit -1
end

begin
  require 'xml'
rescue LoadError
  $stderr.puts "#{$0} requires installed libxml-ruby ruby gem\nTry $sudo gems install -r libxml-ruby\n"
  exit -1
end

def print_usage()
  $stderr.puts "It validates xml file against xsd schema file\n"
  $stderr.puts "Usage: #{$0} xml_file.xml schema_file.xsd\n"
end

def validate(xml, xsd)
  doc = LibXML::XML::Document.file(xml)
  schema_doc = LibXML::XML::Document.file(xsd)

  schema = LibXML::XML::Schema.document schema_doc

  return doc.validate_schema(schema)
end

if __FILE__ == $0
  
  if ARGV.length != 2
    print_usage()
    exit -1
  elsif ARGV[0][-3..-1] != "xml"
    $stderr.puts "First argument must be xml file with '.xml' extension\n"
    exit -1
  elsif ARGV[1][-3..-1] != "xsd"
    $stderr.puts "Second argument must be xsd file with '.xsd' extension\n"
    exit -1
  end
  
  if validate(ARGV[0],ARGV[1])
    puts "#{ARGV[0].split('/')[-1]} is valid against #{ARGV[1].split('/')[-1]} schema\n"
  end
end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "RRD"

require 'rubygems'
require 'ActiveSupport'

module Activerrd
  class ActiverrdError < StandardError; end
  class NoKeyProvided < ActiverrdError; end
  
  VERSION = '0.0.1'
  RRDS_LOCATION = '../' #TODO: deugly
  
  ARCHIVE_DEFAULTS = {
    :xff=>0.5,
    :type=>:average,
    :steps=>2,
    :rows=>5
  }
    
     GRAPH_DEFAULTS = {
       :title => '',
       :start => Time.new-1.day,
       :end => Time.new,
       :interlace => true,
       :format => 'PNG',
       :width => 450
     }

  
  def self.base_directory
    RRDS_LOCATION
  end
  
  class Base
    @@sources = {}
    @@archives = []
    @@key = nil
    
    def initialize(*args)
      @vals = {}
    end

    def save
      self.class.connect!
      
      time = @created_at || Time.now.to_i.to_s
      RRD.update(self.class.filename, values_template, "#{time}:#{values_string}")
    end
    
    def values_template
      '-t' + @vals.keys.join(':')
    end
    
    def values_string
      @vals.values.join(':')
    end
    
    def created_at=(val)
      if val.is_a? Time then
        @created_at = val.to_i.to_s
      elsif val.is_a? Integer then
        @created_at = val
      end
    end
   
    # Class methods
    # option 2 : 
    
    class << self
    
      def filename
        Activerrd.base_directory + name.to_s.demodulize + db_key + '.rrd'
      end
    
      def destroy!
        File.delete(filename) rescue nil
      end
    
    end
    
    
    def self.db_key #TODO: refactor
      if @@key then
          return @key if @key
          raise NoKeyProvided if @@key_required
      end
      ''
    end
   
    def self.connect!
      unless File.exists?(filename)
       RRD.create(filename,
          "--step", @@step,
          *(datasource_strings+archive_strings))
      end
    end
   
   def self.datasource_strings
      @@sources.collect{|name,opts|
        "DS:#{name}:#{opts[:type].to_s.upcase}:#{opts[:heartbeat]}:#{opts[:min]}:#{opts[:max]}"
      }
   end
   
   def self.archive_strings
     @@archives.collect{|opts|
       "RRA:#{opts[:type].to_s.upcase}:#{opts[:xff]}:#{opts[:steps]}:#{opts[:rows]}"
       }
   end
   
    def self.find(*args)
      consolidation_function=args[0]
      options = args.extract_options!
      connect!
      RRD.fetch(filename, "--start", options[:start].to_i.to_s, "--end", options[:end].to_i.to_s, "AVERAGE")
    end
 
   def self.graph(*args)
     options = GRAPH_DEFAULTS.merge(args.extract_options!)
     
     connect!
     
    graph_path = '/tmp/' + Time.new.to_i.to_s + '.png'
   
     RRD.graph(graph_path,
         "--title", " RubyRRD Demo", 
         "--start", options[:start].to_i.to_s,
         "--end", options[:end].to_i.to_s,
         "--imgformat", options[:format],
         "--width=#{options[:width]}",
         "DEF:foos=#{filename}:foos:AVERAGE",
         "DEF:bars=#{filename}:bars:AVERAGE",
         "CDEF:line=TIME,2400,%,300,LT,foos,UNKN,IF",
         "AREA:bars#00b6e4:beta",
         "AREA:line#0022e9:alpha",
         "LINE3:line#ff0000")
      
      File.open(graph_path)
   end

   def self.rrd_step(size); @@step = size; end
   
   def self.rrd_data_source(*args)
     name = args[0]
     type = args[1]
     options = args.extract_options!
     
     @@sources.merge!({name => options.merge({:type=>type})})
     
     define_method "#{name}=" do |val|
       @vals[name] = val
     end
    
     define_method name do @vals[name] end
   end
   
   def self.rrd_key(key)
     @@key = key
     
     define_method "#{key}=" do |val|
       @key = val
     end
   end
   
   def self.rrd_archive(*args)
     type = args[0]
     options = args.extract_options!
     
     @@archives << ARCHIVE_DEFAULTS.merge((options.merge({:type=>type})))
   end
   
  end

end
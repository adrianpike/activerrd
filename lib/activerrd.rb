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
  
  def self.base_directory
    RRDS_LOCATION
  end
  
  class Base
    @@sources = {}
    @@archives = {}
    @@key = nil
    
    def initialize(filename = nil, options = {})
      @vals = {}
    end
    
    def filename
      Activerrd.base_directory + self.class.name.to_s.demodulize + db_key + '.rrd'
    end
    
    def db_key #TODO: refactor
      if @@key then
          return @key if @key
          raise NoKeyProvided if @@key_required
      end
      ''
    end
    
    def step_size;@@step;end
    
    def find(*args)
      consolidation_function=args[0]
      options = args.extract_options!
      
      RRD.fetch(filename, "--start", start_time.to_s, "--end", end_time.to_s, "AVERAGE")
    end
  
    def graph(*args)
      options = args.extract_options!
    end

    def save
    end
   
   # Class methods
   # option 2 : class << self
   
   def self.rrd_step(size); @@step = size; end
   
   def self.rrd_data_source(*args)
     name = args[0]
     type = args[1]
     options = args.extract_options!
     
     @@sources.merge({name => options.merge({:type=>type})})
     
     define_method "#{name}=" do |val|
       @vals[name] = val
       p "#{name} -- SET TO #{val}"
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
     options = args.extract_options!
     
     @@archives.merge(options)
   end
   
  end

end
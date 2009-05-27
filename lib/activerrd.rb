$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Activerrd
  VERSION = '0.0.1'
  RRDS_LOCATION = '../' #TODO: deugly
  
  def self.base_directory
    RRDS_LOCATION
  end
  
  class Base
    def initialize(filename = nil, *options = {})
      @filename = filename
      
    end
    
    def <<(val)
      # translates roughly to update with a time of now
    end
    
    def find(*args)
      options = args.extract_options!
      
      # translates generally to fetch
    end
    
    def connect! # create blank or open an existing RRD
      
    end
    
    def update
      
    end
    
    def graph
      
    end
    
    def fetch
      
    end
        
    
  end
  
end
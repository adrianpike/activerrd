require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiverrd < Test::Unit::TestCase

  class FooRrd< Activerrd::Base
    rrd_step 300
    
    rrd_data_source 'foos', :gauge, :heartbeat=>600, :min=>0, :max=>100
    rrd_data_source 'bars', :gauge, :heartbeat=>600, :min=>0, :max=>100
    
    rrd_archive :average, :steps=>1, :rows=>300, :xff=>0.5
  end

  def setup
    FooRrd.destroy!
  end
  
  def test_update
    @a = FooRrd.new
    @a.foos=10
    @a.bars=20
    @a.save
  end

  def test_find
    
    # lets get some dummy data into here
    
    Time.now.to_i.step((Time.now.to_i + 300 * 300), 300) { |i|
      @a = FooRrd.new
      @a.foos=rand(100)
      @a.bars=Math.sin(i / 800) * 50 + 50
      @a.created_at = i
      @a.save
    }

    p FooRrd.find(:average, :start=>Time.new, :end=>Time.new+1000.minutes)
  end
  
  def test_graph
    Time.now.to_i.step((Time.now.to_i + 300 * 300), 300) { |i|
      @a = FooRrd.new
      @a.foos=Math.sin(i / 800) * 50 + 50
      @a.bars=rand(100)
      @a.created_at = i
      @a.save
    }
    
    p FooRrd.graph(:start=>Time.new-1.day,:end=>Time.new,:step=>3,:title=>'Foobars')
  end
  
  def test_truth
    assert true
  end
end

require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiverrd < Test::Unit::TestCase
  STEP_SIZE=10

  class FooRrd< Activerrd::Base
    rrd_step STEP_SIZE
    
    rrd_data_source 'foos', :gauge, :heartbeat=>20, :min=>0, :max=>1000
    rrd_data_source 'bars', :gauge, :heartbeat=>20, :min=>0, :max=>1000
    
    rrd_archive :average, :steps=>100
    rrd_archive :max, :steps=>10, :rows=>36
  end

  def setup
    @a = FooRrd.new('test')
  end
  
  def test_step_size; assert @a.step_size == STEP_SIZE; end
  
  def test_update
    @a.foos=10
    @a.bars=20
    @a.save
  end

  def test_find
    p @a.find(:average, :start=>Time.new-1.week, :end=>Time.new)
  end
  
  def test_graph
    @a.graph(:start=>Time.new-1.day,:end=>Time.new,:step=>3,:title=>'Foobars')
  end
  
  def test_truth
    assert true
  end
end

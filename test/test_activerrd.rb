require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiverrd < Test::Unit::TestCase

  def setup
    @a = Activerrd::Base.new
  end
  
  def test_creation
    assert @a
  end
  
  def test_truth
    assert true
  end
end

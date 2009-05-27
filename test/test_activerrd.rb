require File.dirname(__FILE__) + '/test_helper.rb'

class TestActiverrd < Test::Unit::TestCase

  class FooRrd< Activerrd::Base
  end

  def setup
    @a = FooRrd.new('test')
  end
  
  def test_creation
    assert @a
  end
  
  def test_truth
    assert true
  end
end

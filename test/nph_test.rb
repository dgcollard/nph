require "test/unit"
require_relative "../lib/nph/nph.rb"

class NphTest < Test::Unit::TestCase
  
  def test_enumerable_continuous_subsequences
    # can't partition into a negative number of subsequences
    assert_raise(ArgumentError) { [].continuous_subsequences(-1) }
    
    # into zero subsequences
    assert_equal 0, [].continuous_subsequences(0).length
    assert_equal 0, [:a].continuous_subsequences(0).length
    
    # into one subsequence
    l = [:a]
    using l.continuous_subsequences(1) do |p|
      assert_equal 1, p.length
      assert p.include?([l]), "missing partition #{l}"
    end
    
    # into 2 subsequences
    l = [:a]
    using l.continuous_subsequences(2) do |p|
      assert_equal 2, p.length
      
      [[[], [:a]],
       [[:a], []]].each do |q|
         assert p.include?(q), "missing partition #{q.inspect}"
      end
    end
    
    # into 3 subsequences
    l = [:a, :b, :c]
    using l.continuous_subsequences(3) do |p|
      assert_equal 10, p.length
    
      [[[], [], [:a, :b, :c]],
       [[], [:a], [:b, :c]],
       [[], [:a, :b], [:c]],
       [[], [:a, :b, :c], []],
       [[:a], [], [:b, :c]],
       [[:a], [:b], [:c]],
       [[:a], [:b, :c], []],
       [[:a, :b], [], [:c]],
       [[:a, :b], [:c], []],
       [[:a, :b, :c], [], []]].each do |q|
        assert p.include?(q), "missing partition #{q.inspect}"
      end
    end
    
    # there are 3003 ways to partition 10 elements into 6 continuous subsequences
    assert_equal 3003, Array.new(10).continuous_subsequences(6).length
  end
  
end
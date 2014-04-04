require "bigdecimal"
require "matrix"
require_relative "tsp.rb"
require_relative "etsp.rb"

# Passes each argument as an argument to a block, and returns the return value of the block
# 
# using(3, 4) do |x, y|
#   Math.sqrt(x ** 2 + y ** 2)
# end
# => 25
# 
# using "abc" {|s| s.upcase.reverse }
# => "CBA"
def using(*o, &fn)
  fn.call(*o)
end

module Enumerable
  
  # generates all partitions the sequence self into m continuous subsequences
  def continuous_subsequences(m)
    raise ArgumentError, "m can't be negative" if m < 0
    return [] if m == 0
    return [[self]] if m == 1
    
    (0..count).to_enum.flat_map do |i|
      self[i..-1].continuous_subsequences(m - 1).map do |s|
        [self[0...i], *s]
      end
    end
  end
  
end

module Distance
  
  def self.constant(u, v, k = 1)
    k
  end
  
  # Calculates the euclidean distance sqrt(|u-v|) between two vectors u and v. Memoized, so if the 
  # method is called a second time with the same two vectors it returns the same result as the 
  # first time with no recomputation
  def self.euclidean(u, v)
    @@euclidean ||= Hash.new
    @@euclidean[[u, v]] ||= BigDecimal((u - v).magnitude, BigDecimal.double_fig)
  end
  
  # Calculates the taxicab distance between two vectors u and v. Memoized, so if the method is 
  # called a second time with the same two vectors, it returns the same result as the first time 
  # with no recomputation
  def self.taxicab(u, v)
    @@taxicab ||= Hash.new
    @@taxicab[[u, v]] ||= (u - v).map {|c| c.abs }.reduce(:+)
  end
  
end

class Vector
  def x; self[0]; end
  def y; self[1]; end
  def z; self[2]; end
  def x=(new_x); self[0] = new_x; end
  def y=(new_y); self[1] = new_y; end
  def z=(new_z); self[2] = new_z; end
end
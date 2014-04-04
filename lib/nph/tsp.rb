require "bigdecimal"

class Tsp < Array
  
  # Uses the Held-Karp algorithm to find the length of the shortest TSP cycle starting with the 
  # array's first element, travelling to each other element, and returning to the first one.
  # If no block is provided, uses euclidean distance as the default edge cost function
  def cost(&d)
    return 0 if length <= 1
    
    d ||= lambda {|u, v| Distance::euclidean(u, v) }  # default cost function
    
    # Hash keys are of the form [S, i], where S is an set of vertices and i is a vertex, and the 
    # corresponding value is the length of the shortest route that starts with v[0], visits each 
    # vertex in S in any order and finishes with i
    opt = Hash.new do |h, k|
      s, i = *k
      h[k] = (s - [i]).map {|j| h[[s - [i], j]] + d.call(i, j) }.min
    end
    
    # fill hash with base cases
    self[1..-1].each do |v|
      opt[[[v], v]] = d.call(self[0], v)
    end
    
    # shortest length of a cycle from v[0], visiting each city in v[1..n], and returning to v[0]
    opt[[self[1..-1], self[0]]]
  end
  
  # Returns all possible shortest TSP cycles, first by calculating the minimum cost using the 
  # Held-Karp algorithm (see Tsp#cost), then permuting the middle elements to find all cycles
  # with that length
  # If no block is provided, uses euclidean distance as the default edge cost function
  def cycles(&d)
    return [[]] if length == 0
    return [[self[0], self[0]]] if length == 1
    
    d ||= lambda {|u, v| Distance::euclidean(u, v) }  # default cost function
    
    using(cost(&d)) do |c|
      self[1..-1].permutation
        .map {|m| [self[0], *m, self[0]] }
        .select {|p| c == p[0..-2].zip(p[1..-1]).map {|v| d.call(*v) }.reduce(:+) }
    end
  end
  
  # Uses a naive algorithm to find the length of the shortest TSP cycle
  # If no block is provided, uses euclidean distance as the default edge cost function
  def cost_n(&d)
    d ||= lambda {|u, v| Distance::euclidean(u, v) }  # default cost function
    
    permutation.map {|p| p.zip(p.rotate).map {|e| d.call(*e) }.reduce(0, :+) }.min
  end
end

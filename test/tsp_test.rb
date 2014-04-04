require "test/unit"
require_relative "../lib/nph/nph.rb"

class TspTest < Test::Unit::TestCase
  
  def test_tsp_hk
    # empty graph
    g = Tsp[]
    assert_equal 0, g.cost
    assert_equal 1, g.cycles.length
    assert g.cycles.include?([]), "generated cycles #{g.cycles}"
    
    # one vertex
    g = Tsp[0]
    assert_equal 0, g.cost
    assert_equal 1, g.cycles.length
    assert g.cycles.include?([g[0], g[0]]), "generated cycles #{g.cycles}"
    
    # two distinct vertices
    g = Tsp[0, 1]
    assert_equal 2, g.cost
    assert_equal 1, g.cycles.length
    assert g.cycles.include?([0, 1, 0]) or
           g.cycles.include?([1, 0, 1])
    
    # two indistinct vertices
    g = Tsp[0, 0]
    assert_equal 0, g.cost
    assert_equal 1, g.cycles.length
    assert g.cycles.include?([0, 0, 0])
    
    # three vertices
    g = Tsp[0, 1, 2]
    assert_equal 4, g.cost
    assert_equal 2, g.cycles.length
    assert g.cycles.include?([0, 1, 2, 0]) or
           g.cycles.include?([1, 2, 0, 1]) or
           g.cycles.include?([2, 0, 1, 2])
    assert g.cycles.include?([0, 2, 1, 0]) or
           g.cycles.include?([1, 0, 2, 1]) or
           g.cycles.include?([2, 1, 0, 2])
    
    # four vertices
    g = Tsp[-2, 2, 0, 5]
    assert_equal 14, g.cost
    assert_equal 4, g.cycles.length
    assert g.cycles.include?([-2, 2, 5, 0, -2]) or
           g.cycles.include?([2, 5, 0, -2, 2]) or
           g.cycles.include?([0, -2, 2, 5, 0]) or
           g.cycles.include?([5, 0, -2, 2, 5])
    assert g.cycles.include?([-2, 0, 2, 5, -2]) or
           g.cycles.include?([2, 5, -2, 0, 2]) or
           g.cycles.include?([0, 2, 5, -2, 0]) or
           g.cycles.include?([5, -2, 0, 2, 5])
    assert g.cycles.include?([-2, 0, 5, 2, -2]) or
           g.cycles.include?([2, -2, 0, 5, 2]) or
           g.cycles.include?([0, 5, 2, -2, 0]) or
           g.cycles.include?([5, 2, -2, 0, 5])
    assert g.cycles.include?([-2, 5, 2, 0, -2]) or
           g.cycles.include?([2, 0, -2, 5, 2]) or
           g.cycles.include?([0, -2, 5, 2, 0]) or
           g.cycles.include?([5, 2, 0, -2, 5])

    
    # non-scalar vertex objects
    g = Tsp[Vector[0,0], Vector[0,1], Vector[1,1], Vector[1,0]]
    assert_equal 4, g.cost
    assert_equal 2, g.cycles.length
    assert g.cycles.include?([g[0], g[1], g[2], g[3], g[0]]) or
           g.cycles.include?([g[1], g[2], g[3], g[0], g[1]]) or
           g.cycles.include?([g[2], g[3], g[0], g[1], g[2]]) or
           g.cycles.include?([g[3], g[0], g[1], g[2], g[3]])
    assert g.cycles.include?([g[0], g[3], g[2], g[1], g[0]]) or
           g.cycles.include?([g[1], g[0], g[3], g[2], g[1]]) or
           g.cycles.include?([g[2], g[1], g[0], g[3], g[2]]) or
           g.cycles.include?([g[3], g[2], g[1], g[0], g[3]])
    
    
    # custom distance functions
    
    g = Tsp[Vector[0,0], Vector[1,4], Vector[2,1], Vector[3,1], Vector[4,3]]
    assert_equal 5, g.cost {|u, v| Distance::constant(u, v, 1) }
    assert_equal 16, g.cost {|u, v| Distance::taxicab(u, v) }
    assert_equal 12.758, g.cost {|u, v| Distance::euclidean(u, v) }.round(3)
  end
  
  def test_tsp_n
    
    assert_equal 0, Tsp[].cost_n
    assert_equal 0, Tsp[0].cost_n
    assert_equal 2, Tsp[0, 1].cost_n
    assert_equal 0, Tsp[0, 0].cost_n
    assert_equal 4, Tsp[0, 1, 2].cost_n
    assert_equal 14, Tsp[-2, 2, 0, 5].cost_n
    assert_equal 4, Tsp[Vector[0,0], Vector[0,1], Vector[1,1], Vector[1,0]].cost_n

    g = Tsp[Vector[0,0], Vector[1,4], Vector[2,1], Vector[3,1], Vector[4,3]]
    assert_equal 5, g.cost_n {|u, v| Distance::constant(u, v, 1) }
    assert_equal 16, g.cost_n {|u, v| Distance::taxicab(u, v) }
    assert_equal 12.758, g.cost_n {|u, v| Distance::euclidean(u, v) }.round(3)
  end
  
end # TspTest

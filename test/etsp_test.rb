require "test/unit"
require "matrix"
require_relative "../lib/nph/nph.rb"
DEBUG = false
class EtspTest < Test::Unit::TestCase
  
  # test the ETSP solver
  def test_etsp
    g = Etsp[]
    # assert_equal 0, g.cost
    
    g = Etsp[Vector[0,0]]
    # assert_equal 0, g.cost
    
    g = Etsp[Vector[0,0], Vector[1,0]]
    # assert_equal 2.0, g.cost.to_f
    
    g = Etsp[Vector[0,0], Vector[1,0], Vector[1,1]]
    assert_equal 3.414, g.cost.to_f.round(3)
    
    g = Etsp[Vector[0,0], Vector[0,1], Vector[1,0], Vector[1,1]]
    assert_equal 4.0, g.cost.to_f
  end
	
	# test the intext_* functions for checking the relationship of points with lines and polygons
  def test_intext
    # test vertical line
    line = [Vector[0,0], Vector[0,2]]
    assert_equal :on, Etsp.intext_point_line(Vector[0,0], *line)      # on line end
    assert_equal :on, Etsp.intext_point_line(Vector[0,1], *line)      # on line
    assert_equal :on, Etsp.intext_point_line(Vector[0,2], *line)      # on line end
    assert_equal :left, Etsp.intext_point_line(Vector[-1,0], *line)   # left of [0,0]
    assert_equal :left, Etsp.intext_point_line(Vector[-1,1], *line)   # left
    assert_equal :left, Etsp.intext_point_line(Vector[-1,2], *line)   # left of [0,2]
    assert_equal :right, Etsp.intext_point_line(Vector[1,0], *line)   # right of [0,0]
    assert_equal :right, Etsp.intext_point_line(Vector[1,1], *line)   # right
    assert_equal :right, Etsp.intext_point_line(Vector[1,2], *line)   # right of [1,2]
    assert_equal nil, Etsp.intext_point_line(Vector[0,-1], *line)     # below both
    assert_equal nil, Etsp.intext_point_line(Vector[0,3], *line)      # above both
    assert_equal nil, Etsp.intext_point_line(Vector[-1,-1], *line)    # below both
    assert_equal nil, Etsp.intext_point_line(Vector[-1,3], *line)     # above both
    
    # test horizontal line
    line = [Vector[0,0], Vector[2,0]]
    assert_equal :on, Etsp.intext_point_line(Vector[1,0], *line)      # on line
    assert_equal nil, Etsp.intext_point_line(Vector[-1,0], *line)     # left/right is undefined
    assert_equal nil, Etsp.intext_point_line(Vector[3,0], *line)      # left/right is undefined
    assert_equal nil, Etsp.intext_point_line(Vector[1,1], *line)      # above both
    assert_equal nil, Etsp.intext_point_line(Vector[1,-1], *line)     # below both
    
    # test diagonal line
    line = [Vector[0,0], Vector[2,2]]
    assert_equal :on, Etsp.intext_point_line(Vector[1,1], *line)      # on line
    assert_equal :left, Etsp.intext_point_line(Vector[0,1], *line)    # left
    assert_equal :right, Etsp.intext_point_line(Vector[3,1], *line)   # right
    
    # when line segment ends are not distinct
    assert_raise(ArgumentError) { Etsp.intext_point_line(nil, 0, 0) }
    
    # test single point and polygon
    polygon = [Vector[0,0], Vector[2,4], Vector[6,4], Vector[4,0]]
    assert_equal :on, Etsp.intext_point_polygon(Vector[0,0], polygon)     # is vertex
    assert_equal :on, Etsp.intext_point_polygon(Vector[2,4], polygon)     # is vertex
    assert_equal :on, Etsp.intext_point_polygon(Vector[1,2], polygon)     # on edge
    assert_equal :int, Etsp.intext_point_polygon(Vector[2,1], polygon)    # interior
    assert_equal :int, Etsp.intext_point_polygon(Vector[3,1], polygon)    # interior
    assert_equal :ext, Etsp.intext_point_polygon(Vector[0,1], polygon)    # exterior
    
    # test division of point set
    
    ps = [Vector[-1,3], Vector[1, -1], Vector[1,1], Vector[1,3], Vector[2,1], Vector[2,2], Vector[3,1]]
    polygon = [Vector[0,0], Vector[0,2], Vector[2,2], Vector[2,0]]
    
    real_int = [Vector[1,1]]
    real_ext = [Vector[-1,3], Vector[1,-1], Vector[1,3], Vector[3,1]]
    
    int, ext = *Etsp.intext(ps, polygon)
    
    assert int.all? {|p| real_int.include?(p) }, "interior is not #{int.inspect}"
    assert real_int.all? {|p| int.include?(p) }, "interior is not #{int.inspect}"
    assert ext.all? {|p| real_ext.include?(p) }, "exterior is not #{ext.inspect}"
    assert real_ext.all? {|p| ext.include?(p) }, "exterior is not #{ext.inspect}"
  end
  
  # test the inscribe function, which returns a set of points that surround all points it is given
  def test_inscribe
    ps = [Vector[0,2], Vector[2,1], Vector[2,3], Vector[3,0], Vector[3,-2], Vector[4,8], Vector[5,3], Vector[6,1]]
    
    i = Etsp.inscribe(ps)
    int, ext = *Etsp.intext(ps, i)
    
    assert_equal ps.length, int.length, "inscribing points: #{i.inspect}\nincluded: #{int}\nnot included: #{ps - int}"
    assert_equal 0, ext.length
  end
  
  # test the intersect? function, which checks whether two line segments intersect
  def test_intersect
    # lines intersect at an end
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[1,0]], [Vector[0,0], Vector[0,1]])
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[1,1]], [Vector[0,2], Vector[1,1]])
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[1,1]], [Vector[1,1], Vector[2,2]])
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[1,1]], [Vector[2,2], Vector[1,1]])
    
    # lines intersect at a T
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[0,2]], [Vector[1,1], Vector[0,1]])
    
    # lines intersect at a cross
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[2,2]], [Vector[2,0], Vector[0,2]])
    
    # collinear
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[2,0]], [Vector[1,0], Vector[3,0]])
    assert_equal true, Etsp.intersect?([Vector[0,0], Vector[2,0]], [Vector[3,0], Vector[1,0]])
    assert_equal false, Etsp.intersect?([Vector[0,0], Vector[1,1]], [Vector[2,2], Vector[3,3]])
    
    # lines that don't intersect
    assert_equal false, Etsp.intersect?([Vector[0,0], Vector[1,1]], [Vector[1,0], Vector[3,0]])
    assert_equal false, Etsp.intersect?([Vector[0,0], Vector[1,0]], [Vector[0,1], Vector[1,1]])
  end
end
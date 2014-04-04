require "matrix"

class Etsp < Array
  
  def solve
    return [], 0 if length < 2
    
    @@inputs = []
    e, c = Etsp.getsp(self[1..-1], [[self[0], self[0]]])
    
    return e, c
  end
  
  def cycles
    [solve[0]]
  end
  
  def cost
    solve[1]
  end
  
  def self.getsp(v, t)
    if v.length == 0
      e = t
      c = t.map {|t_i| Distance::euclidean(*t_i) }.reduce(:+)
    else
      e = []
      c = Float::INFINITY
      
      gen_cycles(v, t).each do |b|
        inputs = gen_inputs(v, t, b)
        
        if inputs.length > 0
          inputs.each do |r|
            v_a, t_a, v_c, t_c = *r
            e_a, c_a = getsp(v_a, t_a)  # solve interior subproblem
            e_c, c_c = getsp(v_c, t_c)  # solve exterior subproblem
            
            if c.equal?(Float::INFINITY) || c_a + c_c < c # short circuit OR
              e = e_a | e_c
              c = c_a + c_c
            end
          end
        end
      end
    end
    
    return e, c
  end
  
  def self.gen_inputs(v, t, b)
    result = []
    v_a, v_c = *intext(v, b)
    tt_a, tt_c = *intext(t.flatten, b)
    
    (v & b).permutation.each do |v_b_i|
      v_b_i.continuous_subsequences(t.length).each do |q|
        t.length.times do |i|
          t_p = [t[i][0], *q[i].flat_map {|q_i| [q_i, q_i] }, t[i][1]].each_slice(2).to_a
          
          t_p.length.times do |j|
            t_p.combination(j).each do |c|
              t_a = c
              t_c = t_p - c
              
              if t_a.none? {|t_a_j| tt_c.include?(t_a_j[0]) or tt_c.include?(t_a_j[1]) } and
                 t_c.none? {|t_c_j| tt_a.include?(t_c_j[0]) or tt_a.include?(t_c_j[1]) } and
                 not t_a.empty? and not t_c.empty?
                new_input = [v_a, t_a, v_c, t_c]
                
                unless @@inputs.include?(new_input)
                  result << new_input
                  @@inputs << new_input
                end
              end
            end
          end
        end
      end
    end
    
    return result
  end
    
  # generate all usable cycle separators of points in v and t
  def self.gen_cycles(v, t)
    tt = t.flatten
    i = inscribe(v | tt)
    result = []
    u = v | tt | i
    3.upto(Math.sqrt(8 * u.length).floor) do |j|
      u.permutation(j).each do |b|
        # reject cycle if two edges intersect, except when they intersect at the start point of 
        # one and the end point of the other
        if b.zip(b.rotate).permutation(2).none? {|ep| intersect?(*ep) and ep[0][1] != ep[1][0] and ep[0][0] != ep[1][1] }
          v_a, v_c   = *intext(v, b)
          tt_a, tt_c = *intext(tt, b)
          limit = 2 * (v.length + 2 * tt.length) / 3
          
          if (v_a | tt_a).length <= limit and (v_c | tt_c).length <= limit
            result << b
          end
        end
      end
    end
    
    return result
  end
  
  # returns a set of 3 points that inscribe all points in ps
  def self.inscribe(ps)
    min_x, max_x = *ps.minmax_by {|p| p.x }
    min_y, max_y = *ps.minmax_by {|p| p.y }
    
    i_0 = Vector[min_x.x - 1, min_y.y - 1]
    i_1 = Vector[min_x.x - 1, 2 * max_y.y - min_y.y + 1]
    i_2 = Vector[2 * max_x.x - min_x.x + 2, min_y.y - 1]
    
    return i_0, i_1, i_2
  end
  
  # check if line segments a and b intersect
  def self.intersect?(a, b)
    u_a = (b[1].x - b[0].x) * (a[0].y - b[0].y) - (b[1].y - b[0].y) * (a[0].x - b[0].x)
    u_b = (a[1].x - a[0].x) * (a[0].y - b[0].y) - (a[1].y - a[0].y) * (a[0].x - b[0].x)
    v   = (b[1].y - b[0].y) * (a[1].x - a[0].x) - (b[1].x - b[0].x) * (a[1].y - a[0].y)
    
    if v == 0
      return (u_a == 0 and u_b == 0)
    else
      t_a = u_a / v
      t_b = u_b / v
      
      t_a >= 0 and t_a <= 1 and t_b >= 0 and t_b <= 1
    end
  end
  
  # split ps into two sets, one of points inside polygon, and one of points outside polygon (points 
  # neither inside or outside are discarded)
  def self.intext(ps, polygon)
    ps.inject([[], []]) do |a, p|
      case intext_point_polygon(p, polygon)
      when :int
        [a[0] << p, a[1]] # add p to interior point set
      when :ext
        [a[0], a[1] << p] # add p to exterior point set
      else
        a                 # point sets are untouched
      end
    end
  end
  
  # :on is p lies on an edge of polygon, :int if it is inside the polygon, or :ext if it is outside
  def self.intext_point_polygon(p, polygon)
    # if p is a vertex of polygon, p must lie on an edge of polygon
    return :on if polygon.include?(p)
    
    # if p is strictly above, below, left or right of all vertices of polygon, it must be outside of 
    # polygon
    return :ext if polygon.all? {|q| p.x > q.x } or polygon.all? {|q| p.x < q.x } or
                   polygon.all? {|q| p.y > q.y } or polygon.all? {|q| p.y < q.y }
    
    is_int = true # begin inside the polygon
    
    polygon.zip(polygon.rotate).each do |e|
      using intext_point_line(p, *e) do |s|
        if s == :on
          return :on
        elsif s == :right
          is_int = !is_int # each time we cross a line, we move from inside to outside the polygon or 
                           # vice versa
        end
      end
    end
    
    return is_int ? :int : :ext
  end
  
  # :on if p lies on ab, :left if it is to the left, :right if it is to the right, or nil if 
  # it is strictly above or below a and b or ab is horizontal
  def self.intext_point_line(p, a, b)
    raise ArgumentError, "points must not be equal" if a == b 
    
    # if p = a or b then p must lie on ab
    return :on if p == a or p == b
    
    # if p is strictly above a and b, left/right is undefined
    return nil if (p.y > a.y and p.y > b.y) or (p.y < a.y and p.y < b.y)
    
    # when line is horizontal
    if a.y == b.y
      # if p is between a and b
      if (p.x < a.x and p.x > b.x) or (p.x > a.x and p.x < b.x)
        return :on
      else
        return nil
      end
    end
    
    case (p.x - a.x) * (b.y - a.y) <=> (p.y - a.y) * (b.x - a.x)
    when -1
      :left
    when 0
      :on
    when 1
      :right
    end
  end
  
end
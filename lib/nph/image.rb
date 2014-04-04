require "rmagick"
require "matrix"

MARGIN = 25

def draw_image(points, edges, file)
  min_x, max_x = *points.minmax_by {|p| p.x }.map {|p| p.x }
  min_y, max_y = *points.minmax_by {|p| p.y }.map {|p| p.y }

  canvas = Magick::Image.new(max_x + 4 * MARGIN, max_y + 2 * MARGIN, Magick::HatchFill.new('white', 'lightcyan2'))

  gc = Magick::Draw.new


  gc.stroke('red')
  gc.stroke_width(2)
  gc.fill_opacity(0)

  edges.each do |l|
    # draw connecting edges
    gc.line(MARGIN + l[0].x, MARGIN + l[0].y, MARGIN + l[1].x, MARGIN + l[1].y)
  end

  gc.stroke_width(1)

  points.each do |p|
    # draw label
    gc.stroke('transparent')
    gc.fill('black')
    gc.text(MARGIN + p.x + 8, MARGIN + p.y, "(#{p.to_a.join(', ')})")
    
    #draw point
    gc.stroke('black')
    gc.circle(MARGIN + p.x, MARGIN + p.y, MARGIN + p.x + 4, MARGIN + p.y)
  end

  # output image

  gc.draw(canvas)
  canvas.write(file)
end
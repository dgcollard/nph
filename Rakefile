require "rake"
require "rake/testtask"
require "matrix"
require_relative "lib/nph/nph.rb"
require_relative "lib/nph/image.rb"

task :default => [:test]

Rake::TestTask.new("test") do |t|
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = false
  t.warning = true
end

task :tsp do
  tsp = Tsp.new(File.open("tsp.txt").readlines.map {|l|
     Vector[*l.split(" ").map {|k| k.to_i.abs }]
  })
  
  b = tsp.cycles.first
  edges = b.clone.zip(b.rotate)
  
  draw_image(b, edges, "tsp.gif")
  puts "image output in tsp.gif"
end
nph
===

Some solvers for the Travelling Salesperson Problem

Requires
* Ruby >= 1.9.3
* RMagick gem - gem install rmagick
* ImageMagick
* Ghostscript

List a set of points in tsp.txt, then run ```rake tsp```. The program will output an image called tsp.gif with a shortest possible tour of those points.

Example
-------

tsp.txt
```
100 300
217 64
0 0
25 200
100 50
100 225
300 300
250 150
175 225
```

tsp.gif  
![An example TSP tour](https://raw.githubusercontent.com/dgcollard/nph-doc/master/tsp.gif)

Unit tests
----------

Run unit tests contained in test/ with ```rake test```, or just for the solver the image output uses run ```rake test TEST=test/tsp_test.rb```

project('bettercmath', 'd')

sources = files(
  'source/bettercmath/cmath.d',
  'source/bettercmath/easings.d',
  'source/bettercmath/hexagrid2d.d',
  'source/bettercmath/package.d',
  'source/bettercmath/matrix.d',
  'source/bettercmath/misc.d',
  'source/bettercmath/transform.d',
  'source/bettercmath/valuerange.d',
  'source/bettercmath/vector.d',
)
incdir = include_directories('source')

bettercmath = library('bettercmath',
  sources,
  include_directories: incdir,
)

bettercmath_dep = declare_dependency(include_directories: incdir, link_with: bettercmath)

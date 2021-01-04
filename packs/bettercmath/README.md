# bettercmath
A `-betterC` compatible 3D math library for [D](https://dlang.org/).

It is available as a [DUB package](https://code.dlang.org/packages/bettercmath),
has [online documentation](https://bettercmath.dpldocs.info/)
and may be used directly as a [Meson subproject](https://mesonbuild.com/Subprojects.html)
or [wrap](https://mesonbuild.com/Wrap-dependency-system-manual.html).

## Submodules

- **cmath**: Standard math type generic functions and constants, using D runtime ([std.math](https://dlang.org/phobos/std_math.html))
  on [CTFE](https://tour.dlang.org/tour/en/gems/compile-time-function-evaluation-ctfe)
  and C runtime ([core.stdc.math](https://dlang.org/phobos/core_stdc_math.html)) otherwise
- **easings**: Type generic easing functions based on <https://easings.net>
- **hexagrid2d**: 2D Hexagon grid math based on <https://www.redblobgames.com/grids/hexagons>
- **matrix**: Type and dimension generic Matrix type for use in linear algebra
- **misc**: Miscelaneous math functions (angle measure transformation, type generic linear interpolation)
- **transform**: Type and dimension generic Affine Transformations backed by possibly compacted Matrices
- **valuerange**: Inclusive scalar value ranges for interpolating and remapping between ranges
- **vector**: Type and dimension generic Vector type for use in linear algebra

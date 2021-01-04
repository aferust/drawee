chipmunkd
===

D bindings (-betterC) to the 7.X versions of [Chipmunk2D](http://chipmunk-physics.net/), a
physics library.

# Use

You will need to have the chipmunk library installed to use chipmunkd.
You could use something like the following in your `dub.sdl`:

	dependency "chipmunkd" version="<~1.0.0+7.0.1"
	libs "chipmunk"

Note that the version spec `1.0.0+7.0.1` denotes that this is version `1.0.0` of
the chipmunkd bindings, which target the `7.0.1` version of the C library.

The [documentation](http://chipmunk-physics.net/documentation.php) for chipmunk
should mostly apply to the D bindings as well.

# Demos

The `demo` folder contains demo programs ported from the demos included in the C
library. These depend on `glew` and `glfw2`. This is an older version of `glfw`,
so there are some quickly hacked-together bindings in the demo folder to get it
working.

You can build and run the demos using `dub`.

# Comparison to DChip

You might also be interested in [dchip](https://github.com/d-gamedev-team/dchip).
While chipmunkd provides D bindings to the original C library, dchip fully
implements the source in D. With dchip, you don't need to take a dependency on
the original C library, but it may be harder to keep up to date with the
upstream version.

# License

Both chipmunkd and Chipmunk2D are licensed under the 
[MIT License](https://opensource.org/licenses/MIT).

# Credits

These bindings were created with the help of 
[dstep](https://github.com/jacob-carlborg/dstep).

# PAPIF
Simple(-minded) example to use PAPI from Fortran.

We spent far too long putting this together, lacking a better description of the API than can be found in [PAPI's](http://icl.cs.utk.edu/papi) [doxygen](http://icl.cs.utk.edu/papi/docs/d1/d82/group__PAPIF.html). This is very basic, but should help you as a starting point.

Of course you are much better off using tools like [Score-P/Scalasca](http://scalasca.org/), [Likwid](https://github.com/RRZE-HPC/likwid), or [perf](https://perf.wiki.kernel.org/index.php/Main_Page) to instrument/measure your code. This basic approach shown here uses low-level PAPI calls should you long for more fine grained control.

# CHANGE TO MEET YOUR FORTRAN COMPILER
FC = gfortran
FOPTS = -O3 -mtune=native -march=native

# CHANGE THIS TO SUITE YOUR SETUP
PAPIPATH = ${PAPI_HOME}

INCPATH = $(PAPIPATH)/include
LIBS = -lpapi
LIBPATH = $(PAPIPATH)/lib

.PHONY: all clean run
all: papi.x
clean:
	@rm papi.x

papi.x: papi.F90 Makefile
	$(FC) $(FOPTS) -I$(INCPATH) -L$(LIBPATH) $(LIBS) $< -o $@

run: papi.x
	@./papi.x

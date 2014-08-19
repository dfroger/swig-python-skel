PROG='example'
UNAME := $(shell uname)
SHARED_LIB := _$(PROG).so
CFLAGS := -O3 -Wall -g -fPIC
PYTHON_INCLUDES := $(shell python-config --includes)
PYTHON_PREFIX := $(shell python-config --prefix)
PYTHON_LIBS := $(shell python-config --libs)

all: $(PROG) swig test-python

$(PROG):
	$(CC) $(CFLAGS) $(INCLUDES) -c $(PROG).c -o $(SHARED_LIB)

$(PROG)_wrap.c:
	swig -Wall -python -builtin -module $(PROG) -o $(PROG)_wrap.c $(PROG).i
	
$(PROG)_wrap.o:
	$(CC) $(CFLAGS) $(PYTHON_INCLUDES) -c $(PROG)_wrap.c

# OS-dependent shared library flags
ifeq ($(UNAME), Darwin)
    SHLIB_FLAGS = -shared -undefined dynamic_lookup
else
    SHLIB_FLAGS = -pthread -shared -Wl,-O1
endif

$(SHARED_LIB): $(PROG) $(PROG)_wrap.c $(PROG)_wrap.o
ifeq ($(UNAME), Darwin)
	$(CC) $(SHLIB_FLAGS) $(CFLAGS) $(PYTHON_INCLUDES) -o $@ $(PROG)_wrap.o -L$(PYTHON_PREFIX)/lib $(PYTHON_LIB)
else
	$(CC) $(SHLIB_FLAGS) $(CFLAGS) -o $@ $(PROG)_wrap.o
endif

swig: $(SHARED_LIB)
test-python:
	python -c 'import $(PROG)' && echo "Python build is ok!"
clean:
	rm -f *.py *.pyc *_wrap.* *.o _*.so

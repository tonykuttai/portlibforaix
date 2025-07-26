# Makefile for PortlibforAIX
CC=gcc
CFLAGS=-D__PASE__ -fPIC -maix64 -O2
LDFLAGS=-maix64
PREFIX=$(HOME)/local
DESTDIR=

# Ensure we're building in 64-bit mode
export OBJECT_MODE=64

all: build-all
install: install-all

# Main library target - build shared object first
util/libutil.o: util/getopt_long.o util/pty.o util/mkdtemp.o util/backtrace.o util/bsd-flock.o util/asprintf.o util/progname.o util/err.o util/isatty.o util/fnmatch.o
	$(CC) -shared $(CFLAGS) $(LDFLAGS) -Wl,-bE:util/libutil.exp -o $@ $^

# Individual object files
util/%.o: util/%.c
	$(CC) -c $(CFLAGS) -Iutil -o $@ $<

# Generate import file for AIX shared library
util/libutil.imp: util/libutil.exp
	( \
	echo '#! libutil.so.2(shr_64.o)'; \
	echo "# 64"; \
	cat util/libutil.exp; \
	) > util/libutil.imp

# Create AIX-style shared library archive
util/libutil.so.2: util/libutil.o util/libutil.imp
	@echo "Creating AIX shared library archive..."
	cp util/libutil.o util/shr_64.o
	cp util/libutil.imp util/shr_64.imp
	strip -e util/shr_64.o 2>/dev/null || true
	OBJECT_MODE=32_64 ar -X64 crv $@ util/shr_64.o
	rm -f util/shr_64.o util/shr_64.imp

# Create symbolic link for easier linking
util/libutil.so: util/libutil.so.2
	cd util && ln -sf libutil.so.2 libutil.so

# Target marker
util/libutil.target: util/libutil.so
	@touch $@

# Installation rules
install-util-libutil: util/libutil.so util/libutil.so.2
	@echo "Installing libutil to $(DESTDIR)$(PREFIX)..."
	mkdir -p $(DESTDIR)$(PREFIX)/lib
	cp util/libutil.so $(DESTDIR)$(PREFIX)/lib/
	cp util/libutil.so.2 $(DESTDIR)$(PREFIX)/lib/
	mkdir -p $(DESTDIR)$(PREFIX)/include
	mkdir -p $(DESTDIR)$(PREFIX)/include/sys
	cp util/getopt.h $(DESTDIR)$(PREFIX)/include/getopt.h
	cp util/pty.h $(DESTDIR)$(PREFIX)/include/pty.h
	cp util/execinfo.h $(DESTDIR)$(PREFIX)/include/execinfo.h
	cp util/wrapper/file.h $(DESTDIR)$(PREFIX)/include/sys/file.h
	cp util/wrapper/stdio.h $(DESTDIR)$(PREFIX)/include/stdio.h
	cp util/wrapper/unistd.h $(DESTDIR)$(PREFIX)/include/unistd.h
	cp util/wrapper/stdlib.h $(DESTDIR)$(PREFIX)/include/stdlib.h
	cp util/wrapper/fnmatch.h $(DESTDIR)$(PREFIX)/include/fnmatch.h
	cp util/err.h $(DESTDIR)$(PREFIX)/include/err.h
	@echo "Installation complete"

# Main targets
build-all: util/libutil.target

install-all: install-util-libutil

# Test target to verify the library
test: util/libutil.so.2
	@echo "Testing library..."
	file util/libutil.so.2
	ar -tv util/libutil.so.2
	@echo "Library test complete"

# Debugging target
debug:
	@echo "CC=$(CC)"
	@echo "CFLAGS=$(CFLAGS)"
	@echo "LDFLAGS=$(LDFLAGS)"
	@echo "PREFIX=$(PREFIX)"
	@echo "OBJECT_MODE=$(OBJECT_MODE)"

# Clean up build artifacts
.PHONY: clean all install build-all install-all test debug
clean:
	@echo "Cleaning build artifacts..."
	rm -f util/*.a util/*.o util/*.so util/*.so.* util/*.imp util/*.target
	@echo "Clean complete"

# Ensure required directories exist
$(DESTDIR)$(PREFIX)/lib:
	mkdir -p $@

$(DESTDIR)$(PREFIX)/include:
	mkdir -p $@

$(DESTDIR)$(PREFIX)/include/sys:
	mkdir -p $@

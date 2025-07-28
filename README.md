# Porting Library for IBM AIX

## Summary

Provides various functions which are not provided by the AIX runtime. This is forked from [portlibfori](https://github.com/IBM/portlibfori) and modified for AIX runtime.

This makes porting applications easier. Currently provides the following libraries:

### libutil

Contains various functions found in Linux, BSD, etc but not found on AIX:

- openpty
- forkpty
- login_tty
- getopt_long
- getopt_long_only
- mkdtemp
- backtrace
- backtrace_symbols
- libutil_getprogname
- libutil_setprogname

## Building

```shell
    make
    make install
```

The Makefile supports `PREFIX` and `DESTDIR` variables. The default prefix is `$(HOME)/local/portlibforaix`. To install to a different prefix specify it like so:

```shell
    make PREFIX=/dir/my/prefix install
```

## License

Most code is licensed under MIT. See [LICENSE](LICENSE) for more info.

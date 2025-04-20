# Prerequisites

- Msys2 with the following packages:

  | Tool                             | Justification                                      |
  |----------------------------------|----------------------------------------------------|
  | msys/python                      | Needed to run `sources/archives/fetch-sources.py`  |
  | msys/gcc                         | Needed to build `make` and `glibc` headers         |
  | msys/m4                          | Needed to build `make` and `glibc` headers         |
  | msys/rsync                       | Needed to build `make` and `glibc` headers         |
  | msys/make                        | Needed to build `make` and `glibc` headers         |
  | msys/texinfo                     | Needed to build `binutils` docs                    |
  | msys/gettext-devel               | Needed to build `glibc` headers                    |
  | ucrt64/mingw-w64-ucrt-x86_64-gcc | Needed to build native, statically linked binaries |

  "One-liner" for convenience:
  ```sh
  pacman -s \
         msys/python msys/gcc msys/m4 msys/rsync msys/make \
         msys/texinfo msys/gettext-devel ucrt64/mingw-w64-ucrt-x86_64-gcc
  ```

- Access to a Linux host (WSL, Hyper-V or a physical machine) with a C compiler so that you can run
  Linux's `headers_install` target. This does not work cleanly in Msys2 - just don't.

- At least 50GB of disk space

# dev

# TODO:

- []: Define README.md
- []: Add `make upgrade target` command - upgrade dev package and check Makefile -.
- []: `make list-recipe` group recipes by package. 
- []: Check when require that .mk file exists and do not require again.
- []: Add constraining to cli install only works for Darwin.
- []: Add support to cli install for Linux.
- []: Refactor cli install to install without a version, otherwise warn user.
- []: Rename function `strip_output` to `github_strip_output`.


# Note:
An alternative approach is place a link to samplegentool in the GOBIN directory. If your GOBIN is not set, it defaults to GOPATH/bin. If GOPATH is not set either (which is what I do, since I'm all in on modules), it should be in $HOME/go/bin.
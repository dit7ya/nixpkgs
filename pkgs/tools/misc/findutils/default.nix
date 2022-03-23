{ lib, stdenv, fetchurl
, coreutils
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "findutils";
  version = "4.9.0";

  src = fetchurl {
    url = "mirror://gnu/findutils/${pname}-${version}.tar.xz";
    sha256 = "sha256-or+4wJ1DZ3DtxZ9Q+kg+eFsWGjt7nVR1c8sIBl/UYv4=";
  };

  postPatch = ''
    substituteInPlace xargs/xargs.c --replace 'char default_cmd[] = "echo";' 'char default_cmd[] = "${coreutils}/bin/echo";'
  '';

  patches = [ ./no-install-statedir.patch ];

  buildInputs = [ coreutils ]; # bin/updatedb script needs to call sort

  # Since glibc-2.25 the i686 tests hang reliably right after test-sleep.
  doCheck
    =  !stdenv.hostPlatform.isDarwin
    && !(stdenv.hostPlatform.libc == "glibc" && stdenv.hostPlatform.isi686)
    && (stdenv.hostPlatform.libc != "musl")
    && stdenv.hostPlatform == stdenv.buildPlatform;

  outputs = [ "out" "info" ];

  configureFlags = [
    # "sort" need not be on the PATH as a run-time dep, so we need to tell
    # configure where it is. Covers the cross and native case alike.
    "SORT=${coreutils}/bin/sort"
    "--localstatedir=/var/cache"
  ];

  CFLAGS = lib.optionals stdenv.isDarwin [
    # TODO: Revisit upstream issue https://savannah.gnu.org/bugs/?59972
    # https://github.com/Homebrew/homebrew-core/pull/69761#issuecomment-770268478
    "-D__nonnull\\(params\\)="
  ];

  enableParallelBuilding = true;

  meta = {
    homepage = "https://www.gnu.org/software/findutils/";
    description = "GNU Find Utilities, the basic directory searching utilities of the GNU operating system";

    longDescription = ''
      The GNU Find Utilities are the basic directory searching
      utilities of the GNU operating system.  These programs are
      typically used in conjunction with other programs to provide
      modular and powerful directory search and file locating
      capabilities to other commands.

      The tools supplied with this package are:

          * find - search for files in a directory hierarchy;
          * locate - list files in databases that match a pattern;
          * updatedb - update a file name database;
          * xargs - build and execute command lines from standard input.
    '';

    platforms = lib.platforms.all;

    license = lib.licenses.gpl3Plus;
  };
}

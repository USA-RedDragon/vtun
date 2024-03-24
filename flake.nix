{
  description = "Virtual tunnel over TCP/IP networks";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages = rec {
          default = pkgs.stdenv.mkDerivation rec {
            name = "vtun";
            nativeBuildInputs = with pkgs; [
              bison flex gnumake pkg-config
            ];
            buildInputs = with pkgs; [
              zlib lzo openssl
            ];
            src = self;
            configureFlags = [
              "--without-lzo-lib"
              "--with-lzo-headers=${pkgs.lzo}/include/lzo"
              "--with-lzo-lib=${pkgs.lib.getLib pkgs.lzo}/lib"
              "--with-ssl-lib=${pkgs.lib.getLib pkgs.openssl}/lib"
              "--with-ssl-headers=${pkgs.openssl.dev}/include/openssl"
              "--with-blowfish-headers=${pkgs.openssl.dev}/include/openssl"
            ];
            enableParallelBuilding = true;
            buildPhase = "make";
            installPhase = ''make INSTALL_OWNER= DESTDIR="$out" install'';

            meta = {
              description = "virtual tunnel over TCP/IP networks";
              license = pkgs.lib.licenses.gpl2Plus;
              platforms = pkgs.lib.platforms.unix;
              longDescription = ''
                VTun is the easiest way to create virtual tunnels over TCP/IP networks with traffic shaping and compression.

                It supports IP, PPP, SLIP, Ethernet and other tunnel types.

                VTun is easily and highly configurable, it can be used for various network tasks.

                VTun requires the universal TUN/TAP kernel module which can be found at http://vtun.sourceforge.net/tun/index.html or in the 2.4 and newer Linux kernels.

                Note: This program includes an "encryption" feature intended to protect the tunneled data as it travels across the network. However, the protocol it uses is known to be very insecure, and you should not rely on it to deter anyone but a casual eavesdropper. See the included README.Encryption file for more information.
              '';
            };
          };

          vtun = default;
        };

        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              bison flex gnumake pkg-config
              zlib lzo openssl
            ];
          };
        };
      }
    );
}

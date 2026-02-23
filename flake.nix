{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    rust-overlay.url = "github:oxalica/rust-overlay";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, rust-overlay, ... }@inputs:
    inputs.utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" "clippy" ];
        };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        devShells = {
          default = pkgs.mkShell {
            name = "";
            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = with pkgs; [
                rustToolchain
                clang
                llvmPackages_latest.bintools
                just
                rust-analyzer

                udev
                alsa-lib
                vulkan-loader
                xorg.libX11
                xorg.libXcursor
                xorg.libXi
                xorg.libXrandr
                libxkbcommon
                wayland
                glibc.dev
                glib.dev
            ];
            shellHook = ''
              export PATH=$PATH:''$CARGO_HOME:-~/.cargo}/bin
              export LD_LIBRARY_PATH=${
                pkgs.lib.makeLibraryPath [
                  pkgs.vulkan-loader
                  pkgs.libxkbcommon
                  pkgs.wayland
                  pkgs.alsa-lib
                  pkgs.udev
                ]
              }:$LD_LIBRARY_PATH
              export LIBCLANG_PATH="${pkgs.llvmPackages_latest.libclang.lib}/lib"
              export BINDGEN_EXTRA_CLANG_ARGS="-I${pkgs.glibc.dev}/include -I${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include -I${pkgs.glib.dev}/include/glib-2.0 -I${pkgs.glib.out}/lib/glib-2.0/include/"
              export RUSTFLAGS="-C link-arg=-fuse-ld=lld"
              echo "Bevy development environment loaded!"
            '';
          };
        };
      }
    );
}



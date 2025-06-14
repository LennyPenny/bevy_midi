{
  description = "Rust dev shell for Shadplay...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      overlays = [
        (import rust-overlay)
        (self: super: {
          rustToolchain = super.rust-bin.nightly.latest.default.override {
            extensions = [ "rust-src" ];
          };
        })
      ];

      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit overlays system; };
      });
    in
    {
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = (with pkgs; [
            alsa-lib
            cargo-nextest
            clang
            fontconfig
            fontconfig.dev
            freetype.dev
            libxkbcommon
            lld
            openssl
            pkg-config
            rustToolchain
            udev
            vulkan-headers
            vulkan-loader
            vulkan-tools
            vulkan-validation-layers
            wayland
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXrandr
            wgsl-analyzer
            rust-analyzer
          ]) ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [ libiconv ]);

          shellHook = ''
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath [
              pkgs.alsa-lib
              pkgs.udev
              pkgs.vulkan-loader
              pkgs.openssl
              pkgs.alsa-lib
              pkgs.libxkbcommon
              pkgs.wayland

            ]}"
            rustup default nightly
          '';
        };
      });
    };
}

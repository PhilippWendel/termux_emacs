{
  # Based on https://marek-g.github.io/posts/tips_and_tricks/emacs_on_android/
  description = "A Nix flake to patch and resign Termux and Emacs APKs with a shared user ID";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Use https links for the APKs and key as non-flake inputs
    termux-apk-input = {
      url = "https://f-droid.org/repo/com.termux_1022.apk";
      flake = false;
    };
    emacs-apk-input = {
      url = "https://ftp.gnu.org/gnu/emacs/android/emacs-30.2-29-arm64-v8a.apk";
      flake = false;
    };
    # Use the emacs one so we don't have to create our own
    emacs-keystore = {
      url = "https://cgit.git.savannah.gnu.org/cgit/emacs.git/plain/java/emacs.keystore";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      termux-apk-input,
      emacs-apk-input,
      emacs-keystore,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          # Run with: nix build
          default =
            let
              termux-apk = "termux.apk";
              emacs-apk = "emacs.apk";
              key = "emacs.keystore";
            in
            pkgs.stdenv.mkDerivation {
              name = "termux-emacs-signed";
              src = ./.; # Set the source to the current directory
              dontUnpack = true;

              nativeBuildInputs = with pkgs; [
                apksigner
                apktool
                libxslt
              ];

              buildPhase = ''
                # Copy the keystore and APKs to the build directory
                cp ${termux-apk-input.outPath} ${termux-apk}
                cp ${emacs-apk-input.outPath} ${emacs-apk}
                cp ${emacs-keystore.outPath} ${key}

                # Unpack emacs.apk
                apktool d ${emacs-apk}

                # Hardcoded shared_user_label
                SHARED_USER_LABEL="Termux user"

                # Update Emacs' AndroidManifest.xml with the sharedUserId and sharedUserLabel
                xsltproc --stringparam shared_user_label "$SHARED_USER_LABEL" --output emacs/AndroidManifest.xml $src/add_shared_user.xsl emacs/AndroidManifest.xml

                # Add the shared_user_label string to Emacs' strings.xml
                xsltproc --stringparam shared_user_label "$SHARED_USER_LABEL" --output emacs/res/values/strings.xml $src/update_strings.xsl emacs/res/values/strings.xml

                # Rebuild emacs.apk
                apktool b emacs -o ${emacs-apk}

                # Sign termux.apk (already has android:sharedUserId="com.termux" in its manifest)
                apksigner sign --ks ${key} --ks-pass pass:emacs1 ${termux-apk}

                # Sign emacs.apk
                apksigner sign --ks ${key} --ks-pass pass:emacs1 ${emacs-apk}
              '';

              installPhase = ''
                mkdir -p $out
                cp ${termux-apk} $out/
                cp ${emacs-apk} $out/
              '';
            };
        };
      }
    );
}

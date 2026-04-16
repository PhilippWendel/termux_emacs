# termux_emacs

A nix flake that patches and re-signs the [Termux](https://termux.dev) and [Emacs for Android](https://www.gnu.org/software/emacs/manual/html_node/emacs/Android.html) APKs so they share the same user ID. This allows Emacs to call Termux binaries (git, compilers, search tools, etc.) directly.

Based on the guide by [marek-g](https://marek-g.github.io/posts/tips_and_tricks/emacs_on_android/).

This allows the emacs app to call programs installed in termux.

## How it works

Android assigns each app a unique user ID. By setting `android:sharedUserId="com.termux"` in both APKs and signing them with the same certificate, Android grants them access to each others files — so Emacs can read `/data/data/com.termux/` and call Termux binaries directly.

## Downloads

Pre-built APKs are available on the [Releases page](https://github.com/PhilippWendel/termux_emacs/releases).

## Setup

### 1. Install the APKs

Download `termux.apk` and `emacs.apk` from the [latest release](https://github.com/PhilippWendel/termux_emacs/releases/latest) and install both on your Android device.

> **Note:** You must uninstall any existing Termux or Emacs installation first, as the APKs are signed with a different certificate than the originals.

### 2. Set up Termux

Open Termux and run the bootstrap setup. Install any packages you need, for example:

```sh
pkg install git
```

### 3. Configure Emacs

Create `~/.emacs.d/early-init.el` (or add to it) to make Termux binaries available inside Emacs:

```elisp
(when (string-equal system-type "android")
  (let ((termuxpath "/data/data/com.termux/files/usr/bin"))
    (setenv "PATH" (concat (getenv "PATH") ":" termuxpath))
    (setq exec-path (append exec-path (list termuxpath)))))
```

This adds the Termux `bin` directory to Emacs' `PATH` and `exec-path`, so you can use `M-x compile`, `M-x shell`, Magit, LSP servers, and any other tools that rely on external programs.

## Building from source

```sh
nix build
ls result/
```

The `result/` directory will contain `termux.apk` and `emacs.apk`.

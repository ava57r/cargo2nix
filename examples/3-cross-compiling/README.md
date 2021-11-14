# Project with cross compiling

This project needs a build.rs script on the `buildPlatform` and then the outputs
used to create the final binary for the `hostPlatform`.

This example processes some templates using a `build.rs` script on the
`buildPlatform`. For the sake of demonstration, this project will use the
[`ructe`] template engine to generate a statically-embedded template file.

This humble act requires us to build the `build.rs` to run on the builder to
produce output for the host.  We must be cross-compiling aware to accomplish
this.

[`ructe`]: https://github.com/kaj/ructe

## Glossary

Cross compiling generally has a `hostPlatform` where the outputs will run and a
`buildPlatform` where build steps will be performed.  There are generally three
common cases during a cross compile.

- `depsBuildBuild` to make an output on the builder for running on the builder
- `depsBuildHost` to make an output on the builder for running on the host
- `depsHostHost` for runtime deps on the host

When configuring `nixpkgs`, two arguments are very critical:

- `system` this configures what kind of builder will be used.  For example, if
  your machine is a darwin (mac) machine and you specify `x86_64-linux` as the
  system, your nix program will look for a linux builder such as [`nix-docker`]
  and farm the build out to it.  This is because you told nix you want to use a
  linux builder via the `system`.  When you only set `system`, you get a native
  build for that platform, producing output for the same platform.
  
- `crossSystem` this configures the host.  If the host platform does not match
  the build system `system`, then you are cross compiling and the package
  offsets, `depsBuildBuild` etc will be used so that the right dependencies are
  used for all steps of the build.  All the programs that run during the build
  will be native to `system` still, but they will produce output for the
  `crossSystem` host.
  
[`nix-docker`]: https://github.com/LnL7/nix-docker

A `build.rs` script needs to run on our builder and make outputs for the host.

### Macros - Build or Host?

Consider the following:

- [`include_str!()`]
- [`include_bytes!()`]

[`include_str!()`]: https://doc.rust-lang.org/std/macro.include_str.html
[`include_bytes!()`]: https://doc.rust-lang.org/std/macro.include_bytes.html

They are supposed to expand into something that is used in the final binary, but
the expansion will happen while still on the build platform.  Cross compiling is
wonderful!

### Custom Targets

When building for some hosts (targets can be used interchangeably becausee we're
not building making compilers), either the nix or Rust concept of systems might
not line up 100%.  Rust can output bare metal and wasm that nix is generally not
concerned with providing native dependencies for.  In these cases, you really
need control over the exact target.  This is an experimental area, so check open
issues, the github network for this repository, and any open PR's.

## Generating the project

As described in the hello-world example, fire up a Rust bin crate project with
`cargo new cross-compiling`

This should create a new directory called `cross-compiling` containing a mostly
empty `Cargo.toml` and `src/main.rs` file. Make a subdirectory for called `templates`

```bash
cd cross-compiling
mkdir templates
```

The `templates` directory will hold our `ructe` template files. Let's create a
template file in this location named `test.rs.html`:

```text
@(test: &str)

Hello @test
```

This template file enables us to generate the text `Hello <something>` at
runtime. To compile this template file at build time, we need to add the
following line to the `[build-dependencies]` table of the `Cargo.toml`:

```toml
ructe = "0.9.2"
```

Next, we create a [Cargo build script] named `build.rs` at the crate root:

[Cargo build script]: https://doc.rust-lang.org/cargo/reference/build-scripts.html

```rust
use ructe::Ructe;

fn main() {
    Ructe::from_env()
        .expect("ructe")
        .compile_templates("templates")
        .unwrap();
}
```

This build script will generate a Rust source file named `$OUT_DIR/templates.rs`
which we can statically embed into our program with `include_str!()`. Let's open
the `src/main.rs` file and write some code that will do just that:

```rust
//! A program which generates some text using an embedded template.

include!(concat!(env!("OUT_DIR"), "/templates.rs"));

fn main() {
    let mut buf = Vec::new();
    templates::test(&mut buf, "world").unwrap();
    println!("{}", String::from_utf8_lossy(&buf));
}
```

Our `templates/test.rs.html` file has been converted into a callable Rust
function named `templates::tests`. In the above code, we use this function to
generate the UTF-8 byte string `Hello world` and print it to the screen.

Unfortunately, this project will not build under `cargo2nix` by default because
the build script will not be able to locate the `templates` directory. Let's fix
that when we wrap our project with `cargo2nix`, shall we?

## Generating a Cargo.nix

Like the previous example, we generate a `Cargo.lock` and `Cargo.nix` for our
crate by running the two commands below:

```bash
cargo generate-lockfile
cargo2nix -f
```

## Writing the Flake.nix

Here's where things get a lot more interesting than the previous examples.

## Providing Flakes With pkgsCross

It's inconvenient to have to edit a flake for every `system` and `crossSystem`
or `target` configuration.  We want to create a matrix of packages that can be
accessed just like nix pkgs with `nix build
github:nixpkgs/nixpkgs#pkgsCross.aarch64-android.hello`

The flake-utils we've been using so far is not meant to cover this use case.  We
will have to create the matrix and then filter it for cases we can't support.
Nixpkgs does something similar to generate the various `pkgsCross` and
`pkgsCross.<platform>.static` combinations.

Let's create a new file called [`flake.nix`] and declare a function with the
following arguments:

[`flake.nix`]: ./flake.nix

```nix
{
  inputs = {
    cargo2nix.url = "path:../../";
    # Use the github URL for real packages
    # cargo2nix.url = "github:cargo2nix/cargo2nix/master";
    flake-utils.url = "github:numtide/flake-utils"; # only for inputs to follow
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-21.05";
  };

  outputs = { self, nixpkgs, cargo2nix, flake-utils, rust-overlay, ... }:

      # let-in expressions, very similar to Rust's let bindings.  These names
      # are used to express the output but not themselves paths in the output.
      let

        # create nixpkgs that contains rustBuilder from cargo2nix overlay
        pkgs = import nixpkgs {
        
          inherit system; # build platform
          inherit crossSystem; # host platform
          
          overlays = [(import "${cargo2nix}/overlay")
                      rust-overlay.overlay];
        };

        # create the workspace & dependencies package set
        rustPkgs = pkgs.rustBuilder.makePackageSet' {
          rustChannel = "1.56.1";
          packageFun = import ./Cargo.nix;
        };

      in rec {
        # this is the output (recursive) set (expressed for each system)

        # the packages in `nix build .#packages.<system>.<name>`
        packages = {
          # nix build .#cross-compiling
          # nix build .#packages.x86_64-linux.cross-compiling
          cross-compiling = (rustPkgs.workspace.cross-compiling {}).bin;
        };

        # nix build
        defaultPackage = packages.cross-compiling;
      }
    );
}
```

Save the `flake.nix` file and quit. Let's verify this works as expected by
building it!

### :warning: Remember to Add Flake to Version Control

 Remember to add the flake to version control (and `Cargo.nix` and `flake.lock`
while you're at it)

```bash
git init
git add flake.nix
flake check
# generate the flake.lock
git add flake.lock
git add Cargo.nix
```

## Building

First let's build with the default system, which outputs a native binary for our
current platform.  Run:

```bash
nix build
```

This will create a `result` symlink in the current directory with the following
structure:

```text
ls -al result-bin
result-bin -> /nix/store/xfhfa9pshhix98qlxmjmhf9200k4r7id-crate-cross-compiling-0.1.0-bin

tree result-bin
result-bin
└── bin
    └── cross-compiling
```

Running the `cross-compiling` binary will print the templated string to the
screen:

```text
$ ./result/bin/cross-compiling
Hello world

```

### Building on a Remote Builder

**(which could be a local docker)**

If you don't have access to a remote builder, you won't be able to commplete
this step.  You can cross build on Linux for many hosts, but asking for another
builder always requires another machine.  However, if you are on Linux, asking
for a linux builder is the same as the default package, so the command below
will still work.

To set the system from our flake, you can switch up the nix command just a bit:

```bash
nix build .#packages.x86_64-linux.cross-compiling
```

And now you can run the binary using qemu for that same system (or just running
it if you picked your current system):

```bash
nix run github:nixpkgs/nixpkgs#qemu -- result-bin/bin/static-resources
```

### Cross Building

Now we want to see a static musl build for our platform.  This may work.  Keep
in mind that nixpkgs for cross compiling can have spotty support.  It is still
extremely reproducible, but it's easy to break builds when you need to have more
than a few dependencies working for such a weird static build with an
alternative libc interface.

To set the system from our flake, you can switch up the nix command just a bit:

```bash
nix build .#pkgsCross.pkgsMusl.static.cross-compiling
```

Becausee the results are for your host, just with static and musl support, you
can probably run it.

```bash
result-bin/bin/static-resources
```

Also compare the results of the various builds:

```bash
file result-bin/bin/static-resources
```

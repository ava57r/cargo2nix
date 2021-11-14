# This file was @generated by cargo2nix 0.10.0.
# It is not intended to be manually edited.

args@{
  release ? true,
  rootFeatures ? [
    "cross-compiling/default"
  ],
  rustPackages,
  buildRustPackages,
  hostPlatform,
  hostPlatformCpu ? null,
  hostPlatformFeatures ? [],
  codegenOpts ? null,
  profileOpts ? null,
  mkRustCrate,
  rustLib,
  lib,
  workspaceSrc,
}:
let
  workspaceSrc = if args.workspaceSrc == null then ./. else args.workspaceSrc;
in let
  inherit (rustLib) fetchCratesIo fetchCrateLocal fetchCrateGit fetchCrateAlternativeRegistry expandFeatures decideProfile genDrvsByProfile;
  profilesByName = {
  };
  rootFeatures' = expandFeatures rootFeatures;
  overridableMkRustCrate = f:
    let
      drvs = genDrvsByProfile profilesByName ({ profile, profileName }: mkRustCrate ({ inherit release profile hostPlatformCpu hostPlatformFeatures profileOpts codegenOpts; } // (f profileName)));
    in { compileMode ? null, profileName ? decideProfile compileMode release }:
      let drv = drvs.${profileName}; in if compileMode == null then drv else drv.override { inherit compileMode; };
in
{
  cargo2nixVersion = "0.10.0";
  workspace = {
    cross-compiling = rustPackages.unknown.cross-compiling."0.1.0";
  };
  "registry+https://github.com/rust-lang/crates.io-index".arrayvec."0.5.2" = overridableMkRustCrate (profileName: rec {
    name = "arrayvec";
    version = "0.5.2";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "23b62fc65de8e4e7f52534fb52b0f3ed04746ae267519eef2a83941e8085068b"; };
    features = builtins.concatLists [
      [ "array-sizes-33-128" ]
    ];
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".base64."0.11.0" = overridableMkRustCrate (profileName: rec {
    name = "base64";
    version = "0.11.0";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "b41b7ea54a0c9d92199de89e20e58d49f02f8e699814ef3fdf266f6f748d15c7"; };
    features = builtins.concatLists [
      [ "default" ]
      [ "std" ]
    ];
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".bitflags."1.3.2" = overridableMkRustCrate (profileName: rec {
    name = "bitflags";
    version = "1.3.2";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a"; };
    features = builtins.concatLists [
      [ "default" ]
    ];
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".bytecount."0.6.2" = overridableMkRustCrate (profileName: rec {
    name = "bytecount";
    version = "0.6.2";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "72feb31ffc86498dacdbd0fcebb56138e7177a8cc5cea4516031d15ae85a742e"; };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".cfg-if."1.0.0" = overridableMkRustCrate (profileName: rec {
    name = "cfg-if";
    version = "1.0.0";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd"; };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".either."1.6.1" = overridableMkRustCrate (profileName: rec {
    name = "either";
    version = "1.6.1";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "e78d4f1cc4ae33bbfc157ed5d5a5ef3bc29227303d595861deb238fcec4e9457"; };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".itertools."0.8.2" = overridableMkRustCrate (profileName: rec {
    name = "itertools";
    version = "0.8.2";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "f56a2d0bc861f9165be4eb3442afd3c236d8a98afd426f65d92324ae1091a484"; };
    features = builtins.concatLists [
      [ "default" ]
      [ "use_std" ]
    ];
    dependencies = {
      either = rustPackages."registry+https://github.com/rust-lang/crates.io-index".either."1.6.1" { inherit profileName; };
    };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".lexical-core."0.7.6" = overridableMkRustCrate (profileName: rec {
    name = "lexical-core";
    version = "0.7.6";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "6607c62aa161d23d17a9072cc5da0be67cdfc89d3afb1e8d9c842bebc2525ffe"; };
    features = builtins.concatLists [
      [ "arrayvec" ]
      [ "correct" ]
      [ "default" ]
      [ "ryu" ]
      [ "static_assertions" ]
      [ "std" ]
      [ "table" ]
    ];
    dependencies = {
      arrayvec = rustPackages."registry+https://github.com/rust-lang/crates.io-index".arrayvec."0.5.2" { inherit profileName; };
      bitflags = rustPackages."registry+https://github.com/rust-lang/crates.io-index".bitflags."1.3.2" { inherit profileName; };
      cfg_if = rustPackages."registry+https://github.com/rust-lang/crates.io-index".cfg-if."1.0.0" { inherit profileName; };
      ryu = rustPackages."registry+https://github.com/rust-lang/crates.io-index".ryu."1.0.5" { inherit profileName; };
      static_assertions = rustPackages."registry+https://github.com/rust-lang/crates.io-index".static_assertions."1.1.0" { inherit profileName; };
    };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".md5."0.7.0" = overridableMkRustCrate (profileName: rec {
    name = "md5";
    version = "0.7.0";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "490cc448043f947bae3cbee9c203358d62dbee0db12107a74be5c30ccfd09771"; };
    features = builtins.concatLists [
      [ "default" ]
      [ "std" ]
    ];
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".memchr."2.4.1" = overridableMkRustCrate (profileName: rec {
    name = "memchr";
    version = "2.4.1";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "308cc39be01b73d0d18f82a0e7b2a3df85245f84af96fdddc5d202d27e47b86a"; };
    features = builtins.concatLists [
      [ "std" ]
      [ "use_std" ]
    ];
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".nom."5.1.2" = overridableMkRustCrate (profileName: rec {
    name = "nom";
    version = "5.1.2";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "ffb4262d26ed83a1c0a33a38fe2bb15797329c85770da05e6b828ddb782627af"; };
    features = builtins.concatLists [
      [ "alloc" ]
      [ "default" ]
      [ "lexical" ]
      [ "lexical-core" ]
      [ "std" ]
    ];
    dependencies = {
      lexical_core = rustPackages."registry+https://github.com/rust-lang/crates.io-index".lexical-core."0.7.6" { inherit profileName; };
      memchr = rustPackages."registry+https://github.com/rust-lang/crates.io-index".memchr."2.4.1" { inherit profileName; };
    };
    buildDependencies = {
      version_check = buildRustPackages."registry+https://github.com/rust-lang/crates.io-index".version_check."0.9.3" { profileName = "__noProfile"; };
    };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".ructe."0.9.2" = overridableMkRustCrate (profileName: rec {
    name = "ructe";
    version = "0.9.2";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "c85620b8046f88a870d93d90fa56904dec76cc79139bfcc22e71e87f0cd2169f"; };
    dependencies = {
      base64 = rustPackages."registry+https://github.com/rust-lang/crates.io-index".base64."0.11.0" { inherit profileName; };
      bytecount = rustPackages."registry+https://github.com/rust-lang/crates.io-index".bytecount."0.6.2" { inherit profileName; };
      itertools = rustPackages."registry+https://github.com/rust-lang/crates.io-index".itertools."0.8.2" { inherit profileName; };
      md5 = rustPackages."registry+https://github.com/rust-lang/crates.io-index".md5."0.7.0" { inherit profileName; };
      nom = rustPackages."registry+https://github.com/rust-lang/crates.io-index".nom."5.1.2" { inherit profileName; };
    };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".ryu."1.0.5" = overridableMkRustCrate (profileName: rec {
    name = "ryu";
    version = "1.0.5";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "71d301d4193d031abdd79ff7e3dd721168a9572ef3fe51a1517aba235bd8f86e"; };
  });
  
  "unknown".cross-compiling."0.1.0" = overridableMkRustCrate (profileName: rec {
    name = "cross-compiling";
    version = "0.1.0";
    registry = "unknown";
    src = fetchCrateLocal workspaceSrc;
    buildDependencies = {
      ructe = buildRustPackages."registry+https://github.com/rust-lang/crates.io-index".ructe."0.9.2" { profileName = "__noProfile"; };
    };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".static_assertions."1.1.0" = overridableMkRustCrate (profileName: rec {
    name = "static_assertions";
    version = "1.1.0";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "a2eb9349b6444b326872e140eb1cf5e7c522154d69e7a0ffb0fb81c06b37543f"; };
  });
  
  "registry+https://github.com/rust-lang/crates.io-index".version_check."0.9.3" = overridableMkRustCrate (profileName: rec {
    name = "version_check";
    version = "0.9.3";
    registry = "registry+https://github.com/rust-lang/crates.io-index";
    src = fetchCratesIo { inherit name version; sha256 = "5fecdca9a5291cc2b8dcf7dc02453fee791a280f3743cb0905f8822ae463b3fe"; };
  });
  
}

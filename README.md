# Syncthing QPKG builder

This repository includes build scripts for building [awl](https://github.com/anywherelan/awl) (anywherelan) QPKG for
use in QNAP NAS.

## Build

The build depends on Docker and `make`. All other build dependencies are
downloaded in the Docker containers. To invoke the build, run `make out/pkg`.
This builds awl QPKG for different platforms and stores them in
`out/pkg`.

By default, the v0.19.0 awl release is built. To configure the release
number, set the environment variable `AWL_TAG` to the release number, e.g.
`AWL_TAG=v2.0.2 make out/pkg`.

By default, awl uses the port `8639` for its UI. To configure the port,
set the environment variable `AWL_UI_PORT`,
e.g. `AWL_UI_PORT=8384 make out/pkg`.

Alternatively, the automatically built packages can be download from Github
Actions. Packages are built once a week.

## Installation

1. Manually install awl package in QNAP App Center.
2. Access the awl UI via the awl entry in the QNAP menu or access it directly on `http://<ip of your QNAP>:8639/` (use the port defined in `AWL_UI_PORT`).

## License

This repository is licensed under MIT.

## Thanks

This AWL QPKG builder is heavily based on the [Syncthing QPKG builder](https://github.com/breml/syncthing-qpkg/) by Lucas Bremgartner.

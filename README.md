# OpenPonk: OntoUML ModelQuery

[![Nightly](https://github.com/OpenPonk/ontouml-modelquery/actions/workflows/nightly.yml/badge.svg)](https://github.com/OpenPonk/ontouml-modelquery/actions/workflows/nightly.yml) [![Coverage Status](https://coveralls.io/repos/github/OpenPonk/ontouml-modelquery/badge.svg?branch=master)](https://coveralls.io/github/OpenPonk/ontouml-modelquery?branch=master)

Query layer for inspecting and filtering OntoUML-stereotyped UML models built on top of [`ontouml-profile`](https://github.com/OpenPonk/ontouml-profile). Used by [`ontouml-verifications`](https://github.com/OpenPonk/ontouml-verifications) and [`openponk-ontouml-to-uml-transformation`](https://github.com/OpenPonk/openponk-ontouml-to-uml-transformation).

## Installation

See [openponk.org/#direct-installation](https://openponk.org/#direct-installation) for the supported Pharo version.

```smalltalk
Metacello new
	baseline: 'OpenPonkOntoUMLModelQuery';
	repository: 'github://OpenPonk/ontouml-modelquery';
	load.
```

## Documentation

Part of the [OpenPonk](https://openponk.org) platform. For architecture, the repository catalog, and contributing guidelines, see [`OpenPonk/.github`](https://github.com/OpenPonk/.github/blob/main/profile/README.md).

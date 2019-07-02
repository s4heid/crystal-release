# crystal-release

An unofficial bosh-package to vendor [crystal](https://crystal-lang.org).
This package might be useful when authoring a bosh release that requires
crystal as a runtime and/or compilation dependency.


## Requirements

 * [bosh-cli](https://github.com/cloudfoundry/bosh-cli) `v2.0.36`+


## Usage

### General

**Step 1:** Clone this repository and [vendor](https://bosh.io/docs/package-vendoring/#vendor)
`crystal-*` into your release:

```bash
$ git clone https://github.com/s4heid/crystal-release.git
$ cd ~/workspace/your-release
$ bosh vendor-package crystal-0.29.0 ~/workspace/crystal-release
```

**Step 2:** Add `crystal-*` to the `spec` file of your release:

```yaml
dependencies:
- crystal-0.29.0
```

### Compilation

To use `crystal-*` for compilation in a [packaging script](https://bosh.io/docs/packages/#create-a-packaging-script),
source the `compile.env` script:

```bash
source /var/vcap/packages/crystal-0.29.0/bosh/compile.env
crystal build ...
```

### Runtime

To use `crystal-*` at runtime in a packaging script, source the `runtime.env`
script:

```bash
source /var/vcap/packages/crystal-0.29.0/bosh/runtime.env
crystal run ...
```


## Development

Execute the tests against a working bosh environment (e.g., on [virtualbox](https://bosh.io/docs/bosh-lite/)).

```bash
$ ./tests/run.sh
```


## License

[MIT License](./LICENSE)

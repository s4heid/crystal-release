# crystal-release

An unofficial bosh-package to vendor [crystal](https://crystal-lang.org).


## Requirements

 * [bosh-cli](https://github.com/cloudfoundry/bosh-cli) `v2.0.36`+


## Usage

Clone this repository and vendor the crystal release into your release.

```bash
$ git clone https://github.com/s4heid/crystal-release.git
$ cd ~/workspace/your-release
$ bosh vendor-package crystal-0.28.0 ~/workspace/crystal-release
```

After [vendoring](https://bosh.io/docs/package-vendoring/#vendor) `crystal-*`
into your release, you may want to add it to the `spec` file of your release:

```yaml
dependencies:
- crystal-0.28.0
```

#### Compilation

To use `crystal-*` for compilation in a packaging script, source the `compile.env`
script:

```bash
source /var/vcap/packages/crystal-0.28.0/bosh/compile.env
crystal build ...
```

#### Runtime

To use `crystal-*` at runtime in a packaging script, source the `runtime.env`
script:

```bash
source /var/vcap/packages/crystal-0.28.0/bosh/runtime.env
crystal run ...
```


## License

[MIT License](./LICENSE)

fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Mac

### mac generate

```sh
[bundle exec] fastlane mac generate
```

Gerar o projeto Xcode com xcodegen

### mac test

```sh
[bundle exec] fastlane mac test
```

Rodar todos os testes

### mac build

```sh
[bundle exec] fastlane mac build
```

Build para release local

### mac screenshots

```sh
[bundle exec] fastlane mac screenshots
```

Criar screenshots para App Store

### mac release

```sh
[bundle exec] fastlane mac release
```

Build, archive e upload para App Store Connect

### mac upload

```sh
[bundle exec] fastlane mac upload
```

Apenas fazer upload de um build existente

### mac metadata

```sh
[bundle exec] fastlane mac metadata
```

Atualizar apenas metadata (descrição, screenshots, etc)

### mac validate

```sh
[bundle exec] fastlane mac validate
```

Validar o build antes de fazer upload

### mac archive

```sh
[bundle exec] fastlane mac archive
```

Criar archive via Xcode (recomendado para primeira vez)

### mac beta

```sh
[bundle exec] fastlane mac beta
```

Beta: Upload para TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

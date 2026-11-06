# Q Helper

*Plan the workout. Lead the men. Leave the phone alone.*

Q Helper is an offline-first digital Weinke and live-workout companion for
volunteer workout leaders (Qs). It helps a Q prepare a workout, track the
overall finish time, manage intervals, and call audibles without losing the
original plan. It supports the Q; it does not try to be the Q.

**Developer and publisher:** GV5 Technologies LLC
**Source repository and copyright holder (initial):** Dave Vigil

> Q Helper is an independent community project developed by GV5 Technologies LLC and is not affiliated with or endorsed by F3 Nation.

**Status:** pre-release (v0.1 in development). Free; no ads, subscriptions,
accounts, or telemetry.

## Platforms

iOS 17+ and Android 10+ (API 29+), built with Flutter.

## Development

Flutter is managed with [FVM](https://fvm.app). The exact version is pinned in
[`.fvmrc`](.fvmrc).

```sh
brew install fvm            # or see https://fvm.app/documentation/getting-started/installation
fvm install                 # installs the pinned Flutter version
fvm flutter pub get
dart format --output=none --set-exit-if-changed .   # use `fvm dart` if dart is not on PATH
fvm flutter analyze
fvm flutter test
fvm flutter run
```

No Apple or Google credentials are needed to build or test. Official signed
store builds are produced only by the maintainer; see
[docs/release/signing.md](docs/release/signing.md).

Architecture decisions: [docs/architecture/decisions](docs/architecture/decisions).
The product specification is [Q_Helper_v0.1_Open_Source_Spec.md](Q_Helper_v0.1_Open_Source_Spec.md).

## License

Q Helper is free software under the **GNU General Public License v3**
([LICENSE](LICENSE)) **with an additional permission** allowing distribution
through app stores ([APP-STORE-EXCEPTION.md](APP-STORE-EXCEPTION.md)).

Copyright (C) 2026 Dave Vigil and Q Helper contributors. Contributors keep the
copyright in their contributions.

The Q Helper name, app icon, and GV5 Technologies LLC branding are not licensed
under the GPL. Forks may use the code under the license but must not imply they
are the official GV5-signed releases or endorsed by GV5 or F3 Nation.

> The licensing exception and contribution terms are pending legal review. See
> [docs/legal/licensing-policy.md](docs/legal/licensing-policy.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Contributions require DCO sign-off
**and** explicit acceptance of GPLv3 plus the App Store exception. Security
issues: [SECURITY.md](SECURITY.md).

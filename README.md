[![C/C++ make](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/c-cpp.yml/badge.svg?branch=main)](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/c-cpp.yml) [![C/C++ format](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/cppformat.yml/badge.svg?branch=main)](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/cppformat.yml)

# github-actions-cpp

Pour le respect des règles de codage et bonnes pratiques en C++ ...

## clang

Clang est un compilateur libre pour le C, C++ et Objective-C utilisant les bibliothèques LLVM. Son but est de proposer une alternative à GCC. Il est aujourd'hui maintenu par une large communauté, dont de nombreux employés de Apple, Google, ARM ou Mozilla, dans le cadre du projet LLVM.

## clang-format

`clang-format` est utilisé pour formater le code C/C++/Java/JavaScript/JSON/Objective-C/Protobuf/C#.

Installation sous Ubuntu :

```sh
$ sudo apt-get update >/dev/null && sudo apt-get install -y --no-install-recommends clang-format >/dev/null

$ clang-format -help
```

Lien: https://clang.llvm.org/docs/ClangFormat.html

Il existe des règles de codage pré-définies : LLVM, Google, Chromium, Mozilla, WebKit.

Il est aussi possible de les personnaliser dans un fichier `.clang-format` à placer dans le répertoire du projet et en utilisant l'option `-style=file`.

Un moyen simple de créer le fichier `.clang-format` est :

```sh
$ clang-format -style=llvm -dump-config > .clang-format
```

Mais le moyen le plus efficace est d'utiliser un outil de configuration en ligne : https://zed0.co.uk/clang-format-configurator/

Utilisation de base :

- `-n` ou `--dry-run` : ne fait pas réellement les changements de formatage
- `-i` : fait réellement les changements de formatage à l'intérieur du fichier

Exemple pour appliquer les changement de style à tous les fichiers `.h` et `.cpp` du répertoire courant :

```sh
$ find . -regex '.*\.\(cpp\|h\)' -exec clang-format --style=file -i {} \;
```

Voir aussi : `uncrustify`

```yml
name: C/C++ format
on:
  push:
    branches: [ develop ]
  pull_request:
    branches: [ develop ]

jobs:
  clang-format-checking:
    name: Vérification formatage C++
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: RafikFarhad/clang-format-github-action@v1.0.1
        with:
          sources: "*.h,*.cpp"
          style: file
```

## clang-tidy

`clang-tidy` est un outil de « linter » C++ basé sur `clang`. Son objectif est de diagnostiquer et corriger les erreurs de programmation typiques, telles que les violations de style, l'utilisation abusive de l'interface ou les bogues pouvant être déduits via une analyse statique.

Lien : https://clang.llvm.org/extra/clang-tidy/

Installation sous Ubuntu :

```sh
$ sudo apt-get update >/dev/null && sudo apt-get install -y --no-install-recommends clang-tidy >/dev/null

$ clang-tidy --help
```

Commande de base :

```sh
$ clang-tidy *.cpp --quiet -header-filter='.*' -checks=-*,boost-*,bugprone-*,performance-*,readability-*,portability-*,modernize-use-nullptr,clang-analyzer-*,cppcoreguidelines-* --format-style=none -- -std=c++11
```

Voir aussi : `cppcheck`

```yml
name: C/C++ check

on:
  push:
    branches: [ develop ]
  pull_request:
    branches: [ develop ]

jobs:
  check:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
    - name: run check
      run: |
        sudo apt-get update >/dev/null && sudo apt-get install -y --no-install-recommends clang-tidy >/dev/null
        make check
```

Ajoute des commentaires à une _Pull Request_ :

```yml
name: C/C++ analyse
on:
  pull_request:
    branches: [ develop ]
jobs:
  clang-tidy:
    name: clang-tidy
    runs-on: ubuntu-latest
    steps:
      - name : Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name : Vérification
        uses: ZedThree/clang-tidy-review@v0.7.0
        id: review
        with:
          clang_tidy_checks: 'boost-*,bugprone-*,performance-*,readability-*,portability-*,clang-analyzer-*,cppcoreguidelines-*'
      - name : Résultats
        if: steps.review.outputs.total_comments > 0
        run: exit 1
```

## Autres

### uncrustify

Un outil pour formater (_source code beautifier_) du code source C, C++, C#, ObjectiveC, D, Java, Pawn et VALA.

Lien : https://github.com/uncrustify/uncrustify

Installation sous Ubuntu :

```sh
$ sudo apt-get update >/dev/null && sudo apt-get install -y --no-install-recommends uncrustify >/dev/null

$ uncrustify --help
```

Commande de base :

```sh
$ uncrustify -c uncrustify.cfg -f fichier.cpp -l CPP
```

Liens :

- https://github.com/marketplace/actions/c-style-check
- https://github.com/uncrustify/uncrustify

`test-github-actions/.github/workflows/uncrustify.yml` :

```yml
name: C++ Style
on: [ pull_request ]

jobs:
  cpp_style_check:
    runs-on: ubuntu-latest
    name: Check C++ Style
    steps:
    - name: Checkout this commit
      uses: actions/checkout@v2
    - name: Run style checks
      uses: coleaeason/actions-uncrustify@v1

```

### cppcheck

Cppcheck est un outil d'analyse statique pour le code C/C++. Il fournit une analyse de code pour détecter les bogues et les comportements indéfinis et dangereux.

Lien : https://cppcheck.sourceforge.io/

Installation sous Ubuntu :

```sh
$ sudo apt-get update >/dev/null && sudo apt-get install -y --no-install-recommends cppcheck >/dev/null

$ cppcheck --help
```

Commande base :

```sh
$ cppcheck --enable=all --std=c++11 --platform=unix64 --suppress=missingIncludeSystem --quiet .
```

Lien : https://github.com/deep5050/cppcheck-action

`test-github-actions/.github/workflows/cppcheck.yml` :

```yml
name: cppcheck
on: [push]

jobs:
  build:
    name: cppcheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: cppcheck
        uses: deep5050/cppcheck-action@main
        with:
          github_token: ${{ secrets.GITHUB_TOKEN}}
          enable: all
          force_language: c++
          platform: unix64
          std: c++11
          output_file: ./rapport_cppcheck.txt
          other_options: --suppress=missingIncludeSystem --quiet

      - name: publish report
        uses: mikeal/publish-to-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          BRANCH_NAME: 'develop'
```

## C/C++ Build

`test-github-actions/.github/workflows/c-cpp.yml` :

```yml
name: C/C++ Build

on:
  push:
    branches: [ develop ]
  pull_request:
    branches: [ develop ]

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
    - name: make
      run: make
```

## Voir aussi

Pour Qt : https://github.com/btssn-lasalle84/github-actions-qt

---
Thierry Vaira : **[tvaira(at)free(dot)fr](tvaira@free.fr)**

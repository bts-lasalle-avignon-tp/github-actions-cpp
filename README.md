[![C/C++ make](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/c-cpp.yml/badge.svg?branch=main)](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/c-cpp.yml) [![C/C++ format](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/cppformat.yml/badge.svg?branch=main)](https://github.com/btssn-lasalle84/github-actions-cpp/actions/workflows/cppformat.yml)

# github-actions-cpp

Pour le respect des règles de codage et bonnes pratiques en C++ ...

- [github-actions-cpp](#github-actions-cpp)
  - [clang](#clang)
  - [clang-format](#clang-format)
  - [clang-tidy](#clang-tidy)
  - [Autres](#autres)
    - [uncrustify](#uncrustify)
    - [cppcheck](#cppcheck)
  - [Exemple : C/C++ make](#exemple--cc-make)
  - [Exécution locale : act](#exécution-locale--act)
  - [Linux, Windows et macOS](#linux-windows-et-macos)
  - [Voir aussi](#voir-aussi)

 ---

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

> cf. `clang -v`

Commande de base :

```sh
$ clang-tidy *.cpp --quiet -header-filter='.*' -checks=-*,boost-*,bugprone-*,performance-*,readability-*,portability-*,modernize-use-nullptr,clang-analyzer-*,cppcoreguidelines-* --format-style=none -- -std=c++11 -std=c++14
```

Liste des vérifications : https://clang.llvm.org/extra/clang-tidy/checks/list.html

> Voir aussi : `cppcheck`

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

## Exemple : C/C++ make

`.github/workflows/make.yml` :

```yml
name: C/C++ make

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main
      - develop

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    - name: make
      run: make
```

## Exécution locale : act

[act](https://github.com/nektos/act) est un outil permettant d'exécuter les _workflows_ GitHub Actions **localement** !

Lien : https://github.com/nektos/act

Installation manuelle :

Il faut préalablement installer les outils [Go](https://golang.org/doc/install).

```bash
git@github.com:nektos/act.git
make test
make install
```

Il y a d'autres procédures d'installatio n ici : https://nektosact.com/installation/index.html

Notamment avec l'extension [GitHub CLI](https://cli.github.com/) :

```bash
gh extension install https://github.com/nektos/gh-act
```

On peut lister les _workflows_ GitHub Actions :

```bash
$ act -l
INFO[0000] Using docker host 'unix:///var/run/docker.sock', and daemon socket 'unix:///var/run/docker.sock' 
Stage  Job ID                 Job name                     Workflow name  Workflow file  Events           
0      check                  check                        C/C++ check    check.yml      push,pull_request
0      clang-format-checking  Vérification formatage C++   C/C++ format   format.yml     push,pull_request
0      build                  build                        C/C++ make     make.yml       push,pull_request
```

Puis les exécuter individuellement :

```bash
$ act -W .github/workflows/make.yml
INFO[0000] Using docker host 'unix:///var/run/docker.sock', and daemon socket 'unix:///var/run/docker.sock' 
[C/C++ make/build] 🚀  Start image=catthehacker/ubuntu:act-latest
[C/C++ make/build]   🐳  docker pull image=catthehacker/ubuntu:act-latest platform= username= forcePull=true
[C/C++ make/build]   🐳  docker create image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[] network="host"
[C/C++ make/build]   🐳  docker run image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[] network="host"
[C/C++ make/build]   🐳  docker exec cmd=[node --no-warnings -e console.log(process.execPath)] user= workdir=
[C/C++ make/build] ⭐ Run Main actions/checkout@v4
[C/C++ make/build]   🐳  docker cp src=/mnt/sda/home/tv/Documents/git/MP25-T0-PICKOMINO/. dst=/mnt/sda/home/tv/Documents/git/MP25-T0-PICKOMINO
[C/C++ make/build]   ✅  Success - Main actions/checkout@v4
[C/C++ make/build] ⭐ Run Main make
[C/C++ make/build]   🐳  docker exec cmd=[bash --noprofile --norc -e -o pipefail /var/run/act/workflow/1] user= workdir=
| g++ -std=c++11 -Wall -I. -c -std=c++11 -Wall -I. -o src/ihm.o src/ihm.cpp
| g++ -std=c++11 -Wall -I. -c -std=c++11 -Wall -I. -o src/jeu.o src/jeu.cpp
| g++ -std=c++11 -Wall -I. -c -std=c++11 -Wall -I. -o src/main.o src/main.cpp
| g++ -std=c++11 -Wall -I. -c -std=c++11 -Wall -I. -o src/pickomino.o src/pickomino.cpp
| g++ -o pickomino.out  src/ihm.o src/jeu.o src/main.o src/pickomino.o
[C/C++ make/build]   ✅  Success - Main make
[C/C++ make/build] Cleaning up container for job build
[C/C++ make/build] 🏁  Job succeeded
```

Ou :

```bash
$ act -W .github/workflows/format.yml 
INFO[0000] Using docker host 'unix:///var/run/docker.sock', and daemon socket 'unix:///var/run/docker.sock' 
[C/C++ format/Vérification formatage C++ ] 🚀  Start image=catthehacker/ubuntu:act-latest
[C/C++ format/Vérification formatage C++ ]   🐳  docker pull image=catthehacker/ubuntu:act-latest platform= username= forcePull=true
[C/C++ format/Vérification formatage C++ ]   🐳  docker create image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[] network="host"
[C/C++ format/Vérification formatage C++ ]   🐳  docker run image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[] network="host"
[C/C++ format/Vérification formatage C++ ]   🐳  docker exec cmd=[node --no-warnings -e console.log(process.execPath)] user= workdir=
[C/C++ format/Vérification formatage C++ ]   ☁  git clone 'https://github.com/RafikFarhad/clang-format-github-action' # ref=v1.0.1
[C/C++ format/Vérification formatage C++ ] ⭐ Run Main actions/checkout@v4
[C/C++ format/Vérification formatage C++ ]   🐳  docker cp src=/mnt/sda/home/tv/Documents/git/MP25-T0-PICKOMINO/. dst=/mnt/sda/home/tv/Documents/git/MP25-T0-PICKOMINO
[C/C++ format/Vérification formatage C++ ]   ✅  Success - Main actions/checkout@v4
[C/C++ format/Vérification formatage C++ ] ⭐ Run Main RafikFarhad/clang-format-github-action@v1.0.1
[C/C++ format/Vérification formatage C++ ]   🐳  docker build -t act-rafikfarhad-clang-format-github-action-v1-0-1-dockeraction:latest /home/tv/.cache/act/RafikFarhad-clang-format-github-action@v1.0.1/
[C/C++ format/Vérification formatage C++ ]   🐳  docker pull image=act-rafikfarhad-clang-format-github-action-v1-0-1-dockeraction:latest platform= username= forcePull=false
[C/C++ format/Vérification formatage C++ ]   🐳  docker create image=act-rafikfarhad-clang-format-github-action-v1-0-1-dockeraction:latest platform= entrypoint=[] cmd=[] network="container:act-C-C--format-V-rification-formatage-C-932ae0df5340499f1819126497771d43dcee4619d670e84b8ad01605c443797d"
[C/C++ format/Vérification formatage C++ ]   🐳  docker run image=act-rafikfarhad-clang-format-github-action-v1-0-1-dockeraction:latest platform= entrypoint=[] cmd=[] network="container:act-C-C--format-V-rification-formatage-C-932ae0df5340499f1819126497771d43dcee4619d670e84b8ad01605c443797d"
| [ gh-action ] :: Action started
| [ gh-action ] :: Sources to check: *.h,*.cpp
| 
| [ gh-action ] :: Congrats! The sources are clang formatted.
[C/C++ format/Vérification formatage C++ ]   ✅  Success - Main RafikFarhad/clang-format-github-action@v1.0.1
[C/C++ format/Vérification formatage C++ ] Cleaning up container for job Vérification formatage C++
[C/C++ format/Vérification formatage C++ ] 🏁  Job succeeded
```

## Linux, Windows et macOS

Exemple de _workflow_ utilisant les machines virtuelles **Linux**, **Windows** et **macOS** :

```yml
name: CI

on:
  push:
    branches: [ develop ]
  pull_request:
    branches: [ develop ]

jobs:
  build:

    name: ${{ matrix.toolchain }}
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        toolchain:
          - linux-gcc
          - macos-clang
          - windows-msvc

        include:
          - toolchain: linux-gcc
            os: ubuntu-latest
            compiler: gcc

          - toolchain: macos-clang
            os: macos-latest
            compiler: clang

          - toolchain: windows-msvc
            os: windows-latest
            compiler: msvc

    steps:
    - uses: actions/checkout@v2

    - name: make
      run: make
```

## Voir aussi

Pour Qt : https://github.com/btssn-lasalle84/github-actions-qt

---
Thierry Vaira : **[tvaira(at)free(dot)fr](tvaira@free.fr)**

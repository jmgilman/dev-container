# dev-container

<p align="center">
    <a href="https://github.com/jmgilman/dev-container/actions/workflows/ci.yml">
        <img src="https://github.com/jmgilman/dev-container/actions/workflows/ci.yml/badge.svg"/>
    </a>
    <a href="https://hub.docker.com/repository/docker/jmgilman/dev-container">
        <img src="https://img.shields.io/docker/v/jmgilman/dev-container"/>
    </a>
    <img src="https://img.shields.io/github/license/jmgilman/dev-container"/>
</p>

> A [devcontainer][1] built on Debian and powered by [Nix][2].

## Features

- Based on the stable [Debian slim image][3]
- Includes the [Nix package manager][4]
- Provides a rich [zsh][5] experience
- Packaged with modern tooling (i.e. [fzf][6], [ripgrep][7], etc.)
- Focused on reproducible development environments using [Nix flakes][8].

## Quickstart

Create a `.devcontainer.json` at the root of your repository with the following
contents:

```json
{
  "image": "ghcr.io/jmgilman/dev-container:sha-6124ab0"",
  "mounts": [
    "source=jmgilman-dev,target=/nix,type=volume",
    "source=jmgilman-dev-ext,target=/home/vscode/.vscode-server/extensions,type=volume",
    "source=jmgilman-dev-extin,target=/home/vscode/.vscode-server-insiders/extensions,type=volume"
  ],
  "remoteUser": "vscode",
  "settings": {
    "terminal.integrated.defaultProfile.linux": "zsh",
    "terminal.integrated.profiles.linux": {
      "zsh": {
        "path": "/home/vscode/.nix-profile/bin/zsh"
      }
    }
  }
}
```

Omitting anything from the above example is not recommended. The environment
makes use of a variety of tools including [Oh-My-Zsh][9] and [direnv][10], both
of which rely on the terminal settings above being configured correctly. The
mounted volume names should be changed to reflect your repository name.

## Usage

The container utilizes the common Nix development practice of using direnv with
a [Nix flake][8]. Your repository root should contain a `.envrc` file:

```text
use flake
```

Along with a `flake.nix` file:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShell = pkgs.mkShell {
          packages = [
            pkgs.hello
          ];
        };
      }
    );
}
```

Once the container is loaded, opening up a new shell instance will drop you at
the root of the repository and direnv will automatically load into the
configured [Nix development environment][11].

See the [examples](examples/) directory for more examples. For more detailed
information, see the [getting started guide](docs/getting_started.md).

## Tooling

THe following tools are packaged with the container:

| Name            | Description                                            | Source                                                                |
| --------------- | ------------------------------------------------------ | --------------------------------------------------------------------- |
| `bat`           | A cat(1) clone with wings                              | [Link](https://github.com/sharkdp/bat)                                |
| `batman`        | Read system manual pages using `bat`                   | [Link](https://github.com/eth-p/bat-extras/blob/master/doc/batman.md) |
| `diff-so-fancy` | Good-lookin' diffs                                     | [Link](https://github.com/so-fancy/diff-so-fancy)                     |
| `direnv`        | unclutter your .profile                                | [Link](https://github.com/direnv/direnv)                              |
| `fd`            | A simple, fast and user-friendly alternative to `find` | [Link](https://github.com/sharkdp/fd)                                 |
| `fzf`           | A command-line fuzzy finder                            | [Link](https://github.com/junegunn/fzf)                               |
| `gh`            | Github's official command line tool                    | [Link](https://github.com/cli/cli)                                    |
| `jq`            | Command-line JSON processor                            | [Link](https://github.com/stedolan/jq)                                |
| `ripgrep`       | A modern replacement to `grep`                         | [Link](https://github.com/BurntSushi/ripgrep)                         |
| `tldr`          | Collaborative cheatsheets for console commands         | [Link](https://github.com/tldr-pages/tldr)                            |

Additional required tools should be included in your `flake.nix`. The default
container user has `sudo` privileges if modifications are required.

## Testing

You can run `test/run.sh` to run a rudimentary smoketest on the container. The
test ensures that the image builds and the environment is configured as
expected.

## Contributing

Check out the [issues][12] for items needing attention or submit your own and
then:

1. Fork the repo (<https://github.com/jmgilman/dev-container/fork>)
2. Create your feature branch (git checkout -b feature/fooBar)
3. Commit your changes (git commit -am 'Add some fooBar')
4. Push to the branch (git push origin feature/fooBar)
5. Create a new Pull Request

[1]: https://code.visualstudio.com/docs/remote/containers
[2]: https://nixos.org/
[3]: https://hub.docker.com/_/debian
[4]: https://nixos.wiki/wiki/Nix
[5]: https://www.zsh.org/
[6]: https://github.com/junegunn/fzf
[7]: https://github.com/BurntSushi/ripgrep
[8]: https://nixos.wiki/wiki/Flakes
[9]: https://ohmyz.sh/
[10]: https://direnv.net/
[11]: https://nixos.wiki/wiki/Development_environment_with_nix-shell
[12]: https://github.com/jmgilman/dev-container/issues

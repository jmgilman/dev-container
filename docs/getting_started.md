# Getting Started

The container image is based on [Debian slim][1] and ships with the
[Nix package manager][2] already installed. The command-line environment is
opinionated and uses a combination of [zsh][3] and [Oh-My-Zsh][4] to improve the
overall experience.

The development workflow targets creating reproducible development environments
using [Nix flakes][5]. If you're using this container to contribute to one of my
open source projects you are free to ignore Nix as it will stay out of your way.

Opening a new terminal session in Visual Studio Code will automatically drop
you into a `zsh` environment. If this is the first time loading the environment,
[direnv][6] will activate and setup the development environment. Depending on
the number of tools being compiled, this process may take several minutes. The
example configuration given in the README mounts `/nix` to an external Docker
volume and will dramatically speedup subsequent executions of the container.

Once the environment is activated you'll have access to all of the tooling
required for development. See the [tooling](../README.md#tooling) section of the
README for tools available in the base container. If this is one of my projects,
refer to the README for further instructions on contributing.

The following sections go into more details about the concepts introduced above.

## Container Image

The container image is based on the stable Debian slim image which provides a
minimal but stable environment for running Nix and Visual Studio Code server.
The default container user is `vscode` which is the recommended name, however,
it can be changed by altering the `USER`, `UID`, and `GID` build arguments. The
default user has passwordless `sudo` privileges if needed.

Only the minimal tooling required by Visual Studio Code server is installed
using the built-in package manager (`apt`). The remaining tools are packaged
using Nix.

The container is compiled for both the AMD64 and ARM64 architectures. New
images are released on a weekly basis.

## Nix

The Nix package manager is installed and available in the container. The initial
configuration of the container is done using [home-manager][7]. You can see the
configuration used in [config.nix](../config/config.nix).

Most of the environment configuration is handled by `home-manager` including
providing the base toolset, configuring aliases and environment files, as well
as configuring `zsh` and Oh-My-Zsh.

While not exclusively required, the container does anticipate a `.envrc` file
and a `flake.nix` being at the root of your repository (all of open-source
projects include these files). When the container is loaded, `direnv` will
automatically configure the development environment using the contents of
`flake.nix`.

## Zsh

The shell targeted by the container is `zsh`. Plugins are included to provide
command completion for the tools provided by the base container. The prompt is
provided by [pure prompt][8].

It's important to note that `~/.zshrc` and `~/.zshenv` are both automatically
created by `home-manager` and **cannot** be overriden. If you're using
[dotfiles][9], this may cause unexpected results. The `~/.zshrc` file contains
a line for sourcing `~/.extra` if it's present. As such, it's recommended to
use a [post-start command][10] to move your `.zshrc` file to `~/.extra`.

The `~/.extra` file can also be utilized to hook into other dotfiles as needed.

## Volumes

The example configuration provided in the [quickstart](../README.md#quickstart)
includes mounting volumes for `/nix` as well as the default locations for Visual
Studio code extensions. Failure to mount `/nix` to a volume can result in slow
startup times as the development environment will be disposed of and will need
to be rebuilt when Visual Studio Code is closed.

The volumes can get large depending on the number of tools installed. It's
recommended to dispose of them when you're done contributing to a project.

[1]: https://hub.docker.com/_/debian
[2]: https://nixos.wiki/wiki/Nix
[3]: https://www.zsh.org/
[4]: https://ohmyz.sh/
[5]: https://nixos.wiki/wiki/Flakes
[6]: https://direnv.net/
[7]: https://github.com/nix-community/home-manager
[8]: https://github.com/sindresorhus/pure
[9]: https://code.visualstudio.com/docs/remote/containers#_personalizing-with-dotfile-repositories
[10]: https://code.visualstudio.com/remote/advancedcontainers/start-processes

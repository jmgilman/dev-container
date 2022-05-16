{ config, pkgs, ... }:
{
  # User-specific packages
  home.packages = [
    pkgs.any-nix-shell
    pkgs.bat
    pkgs.bat-extras.batman
    pkgs.curl
    pkgs.diff-so-fancy
    pkgs.direnv
    pkgs.fd
    pkgs.fzf
    pkgs.gawk
    pkgs.git
    pkgs.gh
    pkgs.gnused
    pkgs.jq
    pkgs.less
    pkgs.oh-my-zsh
    pkgs.pure-prompt
    pkgs.ripgrep
    pkgs.tldr
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Enable direnv with nix support
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  # zsh configuration
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "fzf"
        "gh"
        "git"
      ];
      theme = "";
    };

    plugins = [
      {
        name = "you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          sha256 = "/uVFyplnlg9mETMi7myIndO6IG7Wr9M7xDFfY1pG5Lc=";
        };
      }
    ];

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      cat = "bat --paging=never";
      grep = "rg";
      ll = "ls -la";
      man = "batman";
    };

    # Extra environment variables
    envExtra = ''
      # Load exports
      export FZF_DEFAULT_COMMAND='fd --type f'
      if [[ -f $HOME/.extra ]]; then
          source $HOME/.extra
      fi
    '';

    # Extra content for .envrc
    initExtra = ''
      # Setup pure
      fpath+=${pkgs.pure-prompt}/share/zsh/site-functions
      autoload -U promptinit; promptinit
      prompt pure
      zstyle :prompt:pure:path color green

      # Configure any-nix-shell
      any-nix-shell zsh --info-right | source /dev/stdin
    '';

    # Extra content for .envrc loaded before compinit()
    initExtraBeforeCompInit = ''
        '';
  };
}

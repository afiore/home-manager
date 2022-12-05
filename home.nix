{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "a.fiore";
  home.homeDirectory = "/home/a.fiore";

  home.packages = [
    pkgs.htop
    pkgs.bat
    pkgs.kubectl
    pkgs.krew
    pkgs.hex
    pkgs.nixpkgs-fmt
    pkgs.nil
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home = {

    stateVersion = "22.05";

    sessionVariables = {
      "PATH" = "$PATH:$HOME/local/bin:$HOME/.krew/bin";
      "EDITOR" = "${config.programs.vscode.package}/bin/code";
      "PAGER" = "${pkgs.bat}/bin/bat";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;

    history = {
      path = "${config.home.homeDirectory}/.histfile";
      size = 1000000;
      expireDuplicatesFirst = true;
      ignoreSpace = true;
      save = 1000000;
      share = true;
      extended = true;
    };

    shellAliases = {
      "vim" = "nvim";
      "cfgcd" = "cd ~/.config/nixpkgs";
      "cfgbh" = "home-manager build";
      "cfgsh" = "home-manager switch";
      "cfgeh" = "cfgcd && $EDITOR home.nix";
      "cfge" = "cfgcd && $EDITOR configuration.nix";
    };

    initExtra = ''
      # history search
      bindkey "^r" history-incremental-search-backward
    '';

    #TODO: install Cargo via home-manager
    envExtra = ''
      . "$HOME/.cargo/env"
    '';
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "a";
    extraConfig = ''
      bind-key -T prefix | split-window -h
      bind-key -T prefix - split-window
      bind-key -T prefix c new-window -c '#{pane_current_path}'
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };


  programs.vscode = {
    enable = true;

    extensions = [
      pkgs.vscode-extensions.matklad.rust-analyzer
      pkgs.vscode-extensions.vscodevim.vim
    ];

    userSettings = {
      "workbench.colorTheme" = "Default Dark+";
      "security.workspace.trust.untrustedFiles" = "open";
      "window.zoomLevel" = 2;
      "editor.formatOnSave" = true;
      "files.watcherExclude" = {
        "**/.bloop" = true;
        "**/.metals" = true;
        "**/.ammonite" = true;
      };
      "nix.serverPath" = "nil";
      "nix.enableLanguageServer" = true;
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [
              "nixpkgs-fmt"
            ];
          };
        };
      };
    };
  };

  programs.git = {
    enable = true;
    difftastic.enable = true;
    userName = "Andrea Fiore";
    userEmail = "andrea.giulio.fiore@gmail.com";
    aliases = {
      "st" = "status";
      "co" = "checkout";
      "br" = "branch";
    };
  };

  programs.jq = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    withPython3 = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    # Configuration written to ~/.config/starship.toml
    settings = {
      add_newline = false;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      package.disabled = true;
    };
  };
}

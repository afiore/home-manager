{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "a.fiore";
  home.homeDirectory = "/home/a.fiore";

  home.packages = [
    # Editor
    pkgs.vscode
    pkgs.obsidian

    # Utils
    pkgs.htop
    pkgs.bat
    pkgs.hex

    (pkgs.parquet-tools.overridePythonAttrs (old: {
      doCheck = false;
    }))

    # Ops

    pkgs.kubectl
    pkgs.k9s
    pkgs.krew

    # Nix
    pkgs.nixpkgs-fmt
    pkgs.nil
    pkgs.arion
    pkgs.nix-doc
    pkgs.manix

    # Desktop
    pkgs.signal-desktop
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

    # ensure installed programs' icons show up in the launcher UI
    activation = {
      linkDesktopApplications = {
        after = [ "writeBoundary" "createXdgUserDirectories" ];
        before = [ ];
        data = ''
          rm -rf ${config.xdg.dataHome}/"applications/home-manager"
          mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
          cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
        '';
      };
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

    sessionVariables = {
      #"NIX_PATH" = "$HOME/.nix-defexpr/channels_root:$NIX_PATH";
      "EDITOR" = "$HOME/.nix-profile/bin/code -r --wait";
      "PATH" = "$PATH:$HOME/local/bin:$HOME/.krew/bin";
      "PAGER" = "${pkgs.bat}/bin/bat";
      "XDG_DATA_DIRS" = "$XDG_DATA_DIRS:${config.xdg.dataHome}/applications/home-manager";
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
      nfpath=(${pkgs.gradle-completion} \$fpath)
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
      set-option -g renumber-windows on
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = dracula;
        extraConfig = ''
          				set -g @dracula-show-battery true
          				set -g @dracula-show-powerline true
          				set -g @dracula-refresh-rate 10
                  set -g @dracula-plugins "battery cpu-usage git ram-usage"
          			'';
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };


  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = [
      pkgs.vscode-extensions.mkhl.direnv
      pkgs.vscode-extensions.matklad.rust-analyzer
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.ms-azuretools.vscode-docker
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

      gcloud.disabled = true;

      package.disabled = true;
    };
  };
}

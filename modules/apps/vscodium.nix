{ config, inputs, lib, pkgs, self, ... }:

let
  settingsJSON = builtins.toJSON {
    # Bread.
    "breadcrumbs.icons" = false;

    # Editor - behavioural
    "editor.accessibilitySupport" = "off";
    "editor.guides.bracketPairs" = "active";
    "editor.wordWrap" = "on";

    # Editor - appearance
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.fontFamily" = "'Google Sans Code', 'monospace'";
    "editor.fontLigatures" = true;
    "editor.minimap.enabled" = false;
    "editor.scrollbar.horizontal" = "hidden";
    "editor.smoothScrolling" = true;
    "editor.padding.top" = 5;

    # Explorer
    "explorer.compactFolders" = false;
    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;
    "explorer.fileNesting.enabled" = true;
    "explorer.fileNesting.patterns"."flake.nix" = "flake.lock";

    # Files
    "files.autoSave" = "onWindowChange";
    "files.insertFinalNewline" = true;
    "files.trimTrailingWhitespace" = true;
    "files.watcherExclude"."**/.direnv/**" = true;

    # Search
    "search.exclude" = {
      "**/.direnv" = true;
      "**/result" = true;
      "**/result-*" = true;
    };

    # Terminal
    "terminal.integrated.fontFamily" = "'Google Sans Code', 'monospace'";
    "terminal.integrated.gpuAcceleration" = "on";
    "terminal.integrated.stickyScroll.enabled" = false;
    "terminal.integrated.shellIntegration.enabled" = false;
    "terminal.integrated.defaultProfile.linux" = "fish";
    "terminal.integrated.profiles.linux"."fish" = {
      "path" = "/run/current-system/sw/bin/fish";
      "args" = [ "-i" ];
    };

    # Window
    "window.commandCenter" = false;
    "window.dialogStyle" = "custom";
    "window.menuBarVisibility" = "hidden";
    "window.titleBarStyle" = "custom";
    "window.customTitleBarVisibility" = "never";

    # Workbench
    "workbench.colorTheme" = "Dark+";
    "workbench.editor.empty.hint" = "hidden";
    "workbench.editor.enablePreview" = true;
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.layoutControl.enabled" = false;
    "workbench.startupEditor" = "none";
    "workbench.tree.indent" = 16;
    "workbench.sideBar.location" = "right";
    "workbench.tree.renderIndentGuides" = "none";

    # Telemetry
    "telemetry.telemetryLevel" = "off";
    "extensions.autoCheckUpdates" = false;
    "extensions.autoUpdate" = "off";
    "update.mode" = "none";
    "update.showReleaseNotes" = false;

    # Extensions
    "errorLens.gutterIconsEnabled" = true;
    "errorLens.messageBackgroundMode" = "message";

    # Git
    "git.autofetch" = true;
    "git.confirmSync" = true;
    "diffEditor.ignoreTrimWhitespace" = false;

    # Language Server - Nix
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "${lib.getExe pkgs.nixd}";
    "nix.serverSettings"."nixd" = {
      "formatting"."command" = [
        "${lib.getExe inputs.kuro.packages.${pkgs.stdenv.system}.alejandra-custom}"
      ];

      "options"."nixos"."expr" = "(builtins.getFlake \"${self}\").nixosConfigurations.${config.networking.hostName}.options";
    };

    "nix.hiddenLanguageServerErrors" = [
      "textDocument/documentSymbol"
      "textDocument/formatting"
    ];

    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
      "editor.formatOnSave" = true;
    };
  };

  keybindJSON = builtins.toJSON [
    {
      key = "ctrl+l";
      command = "workbench.action.terminal.clear";
      when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
    }
  ];

  argvJSON = builtins.toJSON {
    "enable-crash-reporter" = false;
    "crash-reporter-id" = "00000000-0000-0000-0000-000000000000";
    "password-store" = "gnome-libsecret";
  };
in {
  fonts.packages = [ pkgs.googlesans-code ];
  hjem.users.primaryUser.files = {
    ".vscode-oss/argv.json".text = argvJSON;
    ".config/VSCodium/User/settings.json".text = settingsJSON;
    ".config/VSCodium/User/keybindings.json".text = keybindJSON;
  };

  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with pkgs.vscode-extensions; [
        # Nix
        jnoortheen.nix-ide

        # UI / UX
        pkief.material-icon-theme
        usernamehw.errorlens
      ];
    })
  ];
}

{ pkgs, lib, ... }:

{
  environment.systemPackages = [
    (pkgs.chromium.override {
      enableWideVine = true;
      commandLineArgs = [
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
        "--enable-features=${lib.concatStringsSep "," [
          "AcceleratedVideoEncoder"
          "AcceleratedVideoDecodeLinuxGL"
          "AcceleratedVideoDecodeLinuxZeroCopyGL"
          "VaapiOnNvidiaGPUs"
          "VerticalTabs"
          "JXLImageFormat"
          "MiddleClickAutoscroll"
        ]}"
        "--disable-features=${lib.concatStringsSep "," [
          "WaylandWpColorManagerV1"
        ]}"
      ];
    })
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
    ];

    extraOpts = {
      AIModeSettings = 1; # Disables AI Mode button
      PasswordManagerEnabled = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      EnableMediaRouter = false;
      SpellcheckEnabled = true;
      SpellcheckLanguage = [ "en-GB" "ro" ];
      BookmarkBarEnabled = true;
      ShowHomeButton = false;

      ExtensionInstallBlocklist = [ "*" ];
      ExtensionSettings = {
        "nngceckbapebfimnlniiiahkandclblb"."toolbar_pin" = "force_pinned";
        "ddkjiahejlhfcafbddmgiahcphecmpfh"."toolbar_pin" = "force_pinned";
      };

      "AutoSelectCertificateForUrls" = [
        (builtins.toJSON {
          pattern = "https://[*.]heartblin.eu";
          filter.ISSUER.CN = "Finality Intermediate CA";
        })
      ];
    };
  };

  hjem.users.primaryUser.files = {
    ".config/chromium/Default/Bookmarks".text = builtins.toJSON {
      version = 1;
      checksum = "00000000000000000000000000000000"; # Whatever
      roots = let
        mkUrl = name: url: {
          inherit name url;
          type = "url";
        };

        mkFolder = name: children: {
          inherit name children;
          type = "folder";
        };
      in {
        bookmark_bar = mkFolder "Bookmarks Bar" [
          (mkFolder "Selfhosted" [
            (mkUrl "Beszel" "https://info.heartblin.eu/system/92t2tf4vjx1pw3y")
            (mkUrl "Hydra" "https://hydra.heartblin.eu")
            (mkUrl "Jellyfin" "https://media.heartblin.eu")
            (mkUrl "Nextcloud" "https://files.heartblin.eu")
            (mkUrl "Soulseek" "https://soul.heartblin.eu")
            (mkUrl "VaultWarden" "https://vault.heartblin.eu")
          ])

          (mkFolder "Misc" [
            (mkUrl "Mailbox" "https://app.mailbox.org")
            (mkUrl "YouTube" "https://youtube.com")
            (mkUrl "GitHub" "https://github.com")
            (mkUrl "GitLab" "https://gitlab.com")
            (mkUrl "Teams" "https://teams.microsoft.com/v2/")
          ])

          (mkFolder "Nix" [
            (mkUrl "Functions" "https://noogle.dev/")
            (mkUrl "Options" "https://search.nixos.org/options")
            (mkUrl "Packages" "https://search.nixos.org/packages")
          ])
        ];
        other = mkFolder "Other Bookmarks" [ ];
        synced = mkFolder "Mobile Bookmarks" [ ];
      };
    };
  };
}

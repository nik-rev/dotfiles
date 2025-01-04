{
  pkgs,
  # lib,
  # inputs,
  ...
}:
# let
#   extensions = builtins.trace inputs.nur.modules.homeManager.default.imports (
#     with inputs.nur.modules.homeManager.default.imports.repos.rycee.firefox-addons;
#     [
#       # https://github.com/TLATER/dotfiles/blob/b39af91fbd13d338559a05d69f56c5a97f8c905d/home-config/config/graphical-applications/firefox.nix
#       react-devtools
#       ublock-origin
#       clearurls
#       stylus
#       proton-pass
#       sponsorblock
#     ]
#   );
# in
{
  programs.firefox = {
    enable = true;
    policies = {
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DisablePocker = true;
      DisableFirefoxAccounts = true;
      PromptForDownloadLocation = true;
      # ExtensionSettings = builtins.listToAttrs (
      #   builtins.map (
      #     e:
      #     lib.nameValuePair e.addonId {
      #       installation_mode = "force_installed";
      #       install_url = "file://${e.src}";
      #       updates_disabled = true;
      #     }
      #   ) extensions
      # );
    };
    profiles.nikita = {
      search.force = true;
      search.engines = {
        "GitHub Code" = {
          urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
          definedAliases = [ "@gc" ];
        };
        "GitHub Issues" = {
          urls = [ { template = "https://github.com/search?q={searchTerms}&type=issues"; } ];
          definedAliases = [ "@gi" ];
        };
        "NPM" = {
          urls = [ { template = "https://www.npmjs.com/search?q={searchTerms}"; } ];
          definedAliases = [ "@npm" ];
        };
        "Pkg Size" = {
          urls = [ { template = "https://pkg-size.dev/{searchTerms}"; } ];
          definedAliases = [ "@pkg" ];
        };
        "Home Manager NixOs" = {
          urls = [
            {
              template = "https://home-manager-options.extranix.com/";
              params = [
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@hm" ];
        };
      };
      # extensions = extensions;
      # all settings: https://kb.mozillazine.org/About:config_entries
      settings = {
        "browser.display.background_color.dark" = "#1e1e2e";
        "app.update.auto" = false;
        "browser.discovery.enabled" = false;
        "browser.download.useDownloadDir" = false;
        "browser.startup.homepage" = "about:blank";
        "general.smoothScroll" = true;
        "signon.autofillForms" = false;
        "widget.non-native-theme.scrollbar.style" = 3;
        "browser.uidensity" = 1;
        "browser.compactmode.show" = true;
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.urlbar.suggest.calculator" = true;
        "browser.aboutConfig.showWarning" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.postDownloadThirdPartyPrompt" = false;
        "browser.preferences.moreFromMozilla" = false;
        "browser.tabs.tabmanager.enabled" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        # alt will not open menu
        "ui.key.menuAccessKeyFocuses" = false;
        # new tab page
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        # disable full screen fade animation
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.transition.timeout" = 0;
        "full-screen-api.warning.delay" = 0;
        # disable message "... is now fullscreen"
        "full-screen-api.warning.timeout" = 0;
        # cookie banner handling
        "cookiebanners.service.mode" = 1;
        "cookiebanners.service.mode.privateBrowsing" = 1;
        "cookiebanners.service.enableGlobalRules" = true;
        # disable welcome page
        "browser.aboutwelcome.enabled" = false;
        # dark:0 light:1 system:2 browser:3
        "layout.css.prefers-color-scheme.content-override" = 0;
        # telemetry
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        # passwords
        "signon.rememberSignons" = false;
        "signon.formlessCapture.enabled" = false;
        "signon.privateBrowsingCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;
        # address + credit card manager
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
      };
    };
  };
}

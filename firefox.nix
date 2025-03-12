{
  pkgs-nur,
  lib,
  pkgs-unstable,
  ...
}:
let
  # more extensions are found at https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/addons.json
  extensions = with pkgs-nur.nur.repos.rycee.firefox-addons; [
    ublock-origin
    clearurls
    proton-pass
    sponsorblock
  ];
in
{
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    policies = {
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DisablePocker = true;
      DisableFirefoxAccounts = true;
      PromptForDownloadLocation = true;
      ExtensionSettings = builtins.listToAttrs (
        builtins.map (
          extension:
          lib.nameValuePair extension.addonId {
            installation_mode = "force_installed";
            install_url = "file://${extension.src}";
            updates_disabled = true;
          }
        ) extensions
      );
    };
    profiles.nikita = {
      inherit extensions;
      search.force = true;
      search.engines = {
        "GitHub Code" = {
          urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
          definedAliases = [ "@gh" ];
        };
        "GitHub Issues" = {
          urls = [ { template = "https://github.com/search?q={searchTerms}&type=repositories"; } ];
          definedAliases = [ "@repo" ];
        };
        "Nix Packages" = {
          urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
          definedAliases = [ "@np" ];
        };
        "Home Manager Option Search" = {
          urls = [ { template = "https://home-manager-options.extranix.com/?query={searchTerms}"; } ];
          definedAliases = [ "@hm" ];
        };
        "Crates.io" = {
          urls = [ { template = "https://crates.io/crates/{searchTerms}"; } ];
          definedAliases = [ "@crates" ];
        };
        "YouTube" = {
          urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
          definedAliases = [ "@yt" ];
        };
      };
      # more settings: https://kb.mozillazine.org/About:config_entries
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
        # makes firefox faster
        # https://www.reddit.com/r/swaywm/comments/1iuqclq/firefox_is_now_way_more_efficient_under_sway_it/
        "gfx.webrenderer.compositor.force-enabled" = true;
      };
    };
  };
}

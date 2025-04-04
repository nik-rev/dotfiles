{
  pkgs,
  lib,
  ...
}:
let
  # more extensions are found at https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/addons.json
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin # ad blocker
    clearurls # remove tracking information from URLs
    proton-pass # password manager
    sponsorblock # skip sponsored segments in youtube videos
    simple-translate # translate selected text
  ];
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.u.firefox;
    # all policies: https://mozilla.github.io/policy-templates/
    policies = {
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      AutofillCreditCardEnabled = false;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DisablePocker = true;
      PromptForDownloadLocation = true;
      StartDownloadsInTempDirectory = true;
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
    profiles.nik = {
      inherit extensions;
      search.force = true;
      isDefault = true;
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
        # catppuccin background color
        "browser.display.background_color.dark" = "#1e1e2e";
        "browser.discovery.enabled" = false;
        "browser.startup.homepage" = "about:blank";
        "general.smoothScroll" = true;
        "signon.autofillForms" = false;
        "widget.non-native-theme.scrollbar.style" = 3;
        # use a more dense UI
        "browser.uidensity" = 1;
        "browser.compactmode.show" = true;
        "breakpad.reportURL" = "";
        "browser.urlbar.suggest.calculator" = true;
        # do not send crash reports
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        # do not warn when accessing about:config
        "browser.aboutConfig.showWarning" = false;
        # do not recommend extensions
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.postDownloadThirdPartyPrompt" = false;
        "browser.preferences.moreFromMozilla" = false;
        "browser.tabs.tabmanager.enabled" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        # do not open menu with Alt
        "ui.key.menuAccessKeyFocuses" = false;
        # do not show "Top Sites" in new tab page
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        # do not show "Top Stories" in new tab page
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        # disable full screen fade animation
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.transition.timeout" = 0;
        "full-screen-api.warning.delay" = 0;
        # disable message "... is now fullscreen"
        "full-screen-api.warning.timeout" = 0;
        # disable welcome page when launching firefox for the first time
        "browser.aboutwelcome.enabled" = false;
        # dark:0 light:1 system:2 browser:3
        "layout.css.prefers-color-scheme.content-override" = 0;
        # disable address auto fill
        "extensions.formautofill.addresses.enabled" = false;
        # makes firefox faster in sway
        # https://www.reddit.com/r/swaywm/comments/1iuqclq/firefox_is_now_way_more_efficient_under_sway_it/
        "gfx.webrenderer.compositor.force-enabled" = true;
        # disable "caret"
        "accessibility.browsewithcaret_shortcut.enabled" = false;
      };
    };
  };
}

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
    sponsorblock # auto-skip sponsored segments in youtube videos
    catppuccin-mocha-mauve # color theme
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
      extensions.packages = extensions;
      search.force = true;
      isDefault = true;
      search.engines = {
        github_code = {
          urls = [ { template = "https://github.com/search?q={searchTerms}&type=code"; } ];
          definedAliases = [ "@gh" ];
        };
        github_issues = {
          urls = [ { template = "https://github.com/search?q={searchTerms}&type=repositories"; } ];
          definedAliases = [ "@repo" ];
        };
        nixpkgs = {
          urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
          definedAliases = [ "@np" ];
        };
        home_manager_options = {
          urls = [ { template = "https://home-manager-options.extranix.com/?query={searchTerms}"; } ];
          definedAliases = [ "@hm" ];
        };
        crates_io = {
          urls = [ { template = "https://crates.io/crates/{searchTerms}"; } ];
          definedAliases = [ "@crates" ];
        };
        crate = {
          urls = [ { template = "https://docs.rs/{searchTerms}"; } ];
          definedAliases = [ "@crate" ];
        };
        youtube = {
          urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
          definedAliases = [ "@yt" ];
        };
      };
      # more settings: https://kb.mozillazine.org/About:config_entries
      settings = {
        "browser.discovery.enabled" = false;
        "general.smoothScroll" = true;
        "signon.autofillForms" = false;
        "breakpad.reportURL" = "";
        "extensions.getAddons.showPane" = false;
        "extensions.postDownloadThirdPartyPrompt" = false;
        # When closing the last tab, do not close Firefox
        "browser.tabs.closeWindowWithLastTab" = false;
        # Change the appearance of the scrollbar to a big solid block
        # Makes it easy to find and grab
        #
        # Numbers corresponding to styles
        #
        # 1: Mac OSX
        # 2: GTX
        # 3: Android
        # 4: Windows 10
        # 5: Windows 11
        "widget.non-native-theme.scrollbar.style" = 4;
        # Disable suggestions about seeing more content from mozilla
        "browser.preferences.moreFromMozilla" = false;
        # Disable the tab manager
        "browser.tabs.tabmanager.enabled" = false;
        # Do not show the bookmarks bar. I don't use it
        "browser.toolbars.bookmarks.visibility" = "never";
        # --- disable full screen fade animation
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.transition.timeout" = 0;
        "full-screen-api.warning.delay" = 0;
        # ---
        # --- use a more dense UI
        "browser.uidensity" = 1;
        "browser.compactmode.show" = true;
        # ---
        # do not show "Top Sites" in new tab page
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        # do not show "Top Stories" in new tab page
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        # When searching in the browser tab, shows "search suggestions" before any other
        # suggestion. E.g. I type "You" and it suggest to "YouTube"
        #
        # Without this flag, the auto-complete happens after the browser suggestion.
        # E.g. those might contain things I'm not really interested in like:
        # - Google suggestions: "YouTube" (but just searches the google with this string
        #   and not go to the YouTube website)
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        # Make new tab a blank page
        "browser.newtabpage.enabled" = false;
        # disable address auto fill
        "extensions.formautofill.addresses.enabled" = false;
        # makes firefox faster in sway
        # https://www.reddit.com/r/swaywm/comments/1iuqclq/firefox_is_now_way_more_efficient_under_sway_it/
        "gfx.webrenderer.compositor.force-enabled" = true;
        # dark:0 light:1 system:2 browser:3
        # Always dark theme.
        "layout.css.prefers-color-scheme.content-override" = 0;
        # disable "browse with caret" which I accidentally enable and never use
        "accessibility.browsewithcaret_shortcut.enabled" = false;
        # disable message "... is now fullscreen"
        "full-screen-api.warning.timeout" = 0;
        # disable welcome page when launching firefox for the first time
        "browser.aboutwelcome.enabled" = false;
        # do not open top-left menu with Alt, which has some options
        # I have a lot of keys bound to alt in my windows manager and frequently
        # accidentally activate this
        "ui.key.menuAccessKeyFocuses" = false;
        # do not warn when accessing about:config
        "browser.aboutConfig.showWarning" = false;
        # When typing "2 + 2" in the address bar, it will suggest you the
        # answer, and selecting it copies to the clipboard
        "browser.urlbar.suggest.calculator" = true;
        # Disallow websites from overriding browser shortcuts
        # I use Ctrl + K a lot and websites often override it.
        "permissions.default.shortcuts" = 2;
        # When starting the browser, the opened page is empty
        "browser.startup.homepage" = "about:blank";
        # New tab page is blank
        "browser.newtab.url" = "about:blank";
        # When opening a new tab, it puts the tab after the current tab
        # instead of at the end
        "browser.tabs.insertAfterCurrent" = true;
        # Less animations
        "ui.prefersReducedMotion" = 1;
        # do not recommend extensions
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        # When pressing F11, does not do full screen but hides the title bar and search bar
        # A sort of "zen mode", if you will.
        # from: https://superuser.com/questions/1568072/hide-navigation-bar-in-firefox
        "full-screen-api.ignore-widgets" = true;
        # catppuccin background color
        "browser.display.background_color.dark" = "#1e1e2e";
      };
    };
  };
}

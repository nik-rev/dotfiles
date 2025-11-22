// Locations:
//
// - Linux: ~/.mozilla/firefox/profiles/*/user.js
// - Mac: ~/Library/Application Support/Firefox/Profiles/*/user.js
// - Windows: ~/AppData/Roaming/Mozilla/Firefox/Profiles/*/user.js

user_pref("browser.discovery.enabled", false);
user_pref("general.smoothScroll", true);
user_pref("signon.autofillForms", false);
user_pref("breakpad.reportURL", "");
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.postDownloadThirdPartyPrompt", false);
// When closing the last tab, do not close Firefox
user_pref("browser.tabs.closeWindowWithLastTab", false);
// Change the appearance of the scrollbar to a big solid block
// Makes it easy to find and grab
//
// Numbers corresponding to styles
//
// 1: Mac OSX
// 2: GTX
// 3: Android
// 4: Windows 10
// 5: Windows 11
user_pref("widget.non-native-theme.scrollbar.style", 4);
// Disable suggestions about seeing more content from mozilla
user_pref("browser.preferences.moreFromMozilla", false);
// Disable the tab manager
user_pref("browser.tabs.tabmanager.enabled", false);
// Do not show the bookmarks bar. I don't use it
user_pref("browser.toolbars.bookmarks.visibility", "never");
// --- disable full screen fade animation
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.transition.timeout", 0);
user_pref("full-screen-api.warning.delay", 0);
// ---
// --- use a more dense UI
user_pref("browser.uidensity", 1);
user_pref("browser.compactmode.show", true);
// ---
// do not show "Top Sites" in new tab page
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
// do not show "Top Stories" in new tab page
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
// When searching in the browser tab, shows "search suggestions" before any other
// suggestion. E.g. I type "You" and it suggest to "YouTube"
//
// Without this flag, the auto-complete happens after the browser suggestion.
// E.g. those might contain things I'm not really interested in like:
// - Google suggestions: "YouTube" (but just searches the google with this string
//   and not go to the YouTube website)
user_pref("browser.urlbar.showSearchSuggestionsFirst", false);
// Make new tab a blank page
user_pref("browser.newtabpage.enabled", false);
// disable address auto fill
user_pref("extensions.formautofill.addresses.enabled", false);
// makes firefox faster in sway
// https://www.reddit.com/r/swaywm/comments/1iuqclq/firefox_is_now_way_more_efficient_under_sway_it/
user_pref("gfx.webrenderer.compositor.force-enabled", true);
// dark:0 light:1 system:2 browser:3
// Always dark theme.
user_pref("layout.css.prefers-color-scheme.content-override", 0);
// disable "browse with caret" which I accidentally enable and never use
user_pref("accessibility.browsewithcaret_shortcut.enabled", false);
// disable message "... is now fullscreen"
user_pref("full-screen-api.warning.timeout", 0);
// disable welcome page when launching firefox for the first time
user_pref("browser.aboutwelcome.enabled", false);
// do not open top-left menu with Alt, which has some options
// I have a lot of keys bound to alt in my windows manager and frequently
// accidentally activate this
user_pref("ui.key.menuAccessKeyFocuses", false);
// do not warn when accessing about:config
user_pref("browser.aboutConfig.showWarning", false);
// When typing "2 + 2" in the address bar, it will suggest you the
// answer, and selecting it copies to the clipboard
user_pref("browser.urlbar.suggest.calculator", true);
// Disallow websites from overriding browser shortcuts
// I use Ctrl + K a lot and websites often override it.
user_pref("permissions.default.shortcuts", 2);
// When starting the browser, the opened page is empty
user_pref("browser.startup.homepage", "about:blank");
// New tab page is blank
user_pref("browser.newtab.url", "about:blank");
// When opening a new tab, it puts the tab after the current tab
// instead of at the end
user_pref("browser.tabs.insertAfterCurrent", true);
// Less animations
user_pref("ui.prefersReducedMotion", 1);
// do not recommend extensions
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
// When pressing F11, does not do full screen but hides the title bar and search bar
// A sort of "zen mode", if you will.
// from: https://superuser.com/questions/1568072/hide-navigation-bar-in-firefox
user_pref("full-screen-api.ignore-widgets", true);
// catppuccin background color
user_pref("browser.display.background_color.dark", "#1e1e2e");

const search_engines = {
  g: "https://github.com/search?q={}&type=repositories",
  "lib.rs": "https://lib.rs/crates/{}",
  "docs.rs": "https://docs.rs/{}",
  google: "https://www.google.com/search?q={}",
} as const;
const default_search_engine = search_engines.google;

// Automatically install used addons
{
  const ADDONS = [
    "4598854/ublock_origin-1.67.0",
    "4608179/sponsorblock-6.1.0",
    "3990325/catppuccin_mocha_mauve_git-2.0",
    "4625020/proton_pass-1.33.0",
    "4263531/youtube_recommended_videos-1.6.7"
  ]
  for (const addon of ADDONS) {
    glide.addons.install(`https://addons.mozilla.org/firefox/downloads/file/${addon}.xpi`);
  }
}

// Preferences
{
  glide.prefs.set(
    "signon.rememberSignons",
    false,
  );
  glide.prefs.set("browser.compactmode.show", false)
  glide.o.hint_size = "14px";

  // PREF: disable login manager
  glide.prefs.set("signon.rememberSignons", false);

  // PREF: disable address and credit card manager
  glide.prefs.set("extensions.formautofill.addresses.enabled", false);
  glide.prefs.set("extensions.formautofill.creditCards.enabled", false);
}

const ALL_MODES: GlideMode[] = ["normal", "visual", "insert", "op-pending", "command"]
const VIM_CONTROL: GlideMode[] = ["normal", "visual", "op-pending", "command"]

// Reload the page
glide.keymaps.set("normal", "r", edit_select("r", "reload"))

// Hard-reload the page
glide.keymaps.set("normal", "R", edit_select(null, "config_reload"))

// Open URL
glide.keymaps.set("normal", "o", edit_select(null, "commandline_show open "));

// Open URL in a new tab
glide.keymaps.set("normal", "O", edit_select(null, "commandline_show tab_open "))

// Search through open tabs
glide.keymaps.set("normal", "t", edit_select(null, "commandline_show tab "))

// Duplicate current tab
glide.keymaps.set("normal", "yt", edit_select(null, async ({ tab_id }) => await browser.tabs.duplicate(tab_id)))

// Open the clipboard's URL in the current tab
glide.keymaps.set("normal", "p", edit_select(null, async () => {
  const url = await navigator.clipboard.readText()
  await browser.tabs.update({ url });
}))

// Open the clipboard's URL in a new tab
glide.keymaps.set("normal", "P", edit_select(null, async () => {
  const url = await navigator.clipboard.readText()
  await browser.tabs.create({ url });
}))

// Scroll a half page up: Can't be done, but this is best-effort
glide.keymaps.set("normal", "u", edit_select("undo", "scroll_page_up"))

// Scroll a half page down: Can't be done, but this is best-effort
glide.keymaps.set("normal", "d", edit_select("motion d", "scroll_page_down"))

// track previously active tab
let previousTabId: number | undefined;
browser.tabs.onActivated.addListener((activeInfo) => {
  previousTabId = activeInfo.previousTabId;
});

// Switch to alternate
glide.keymaps.set("normal", "<C-6>", async () => {
  if (previousTabId) {
    await browser.tabs.update(previousTabId, { active: true });
  }
});

// Copy a link to the clipboard
glide.keymaps.set("normal", "yf", () => {
  glide.hints.show({
    // biome-ignore lint/suspicious/noExplicitAny: ...
    action: async (target: any) => {
      if (target.href) {
        await navigator.clipboard.writeText(target.href)
      }
    }
  })
})

// Edit URL.
//
// For some reason, it doesn't work!
glide.keymaps.set("normal", "ge", "keys <C-l>");

// Focus last input
glide.keymaps.set("normal", "gi", async () => {
  await glide.excmds.execute("focusinput last");
  if (!(await glide.ctx.is_editing())) {
    await glide.keys.send("gI");
  }
});

// Search text with "/"
glide.keymaps.set("normal", "/", "keys <C-f>");

// Yank markdown link to page
glide.keymaps.set(
  "normal",
  "ym",
  edit_select(null, async ({ tab_id }) => {
    const tab = await browser.tabs.get(tab_id);
    await navigator.clipboard.writeText(`[${tab.title}](${tab.url})`);
  }),
);

glide.keymaps.set(ALL_MODES, "<C-t>", "tab_prev")
glide.keymaps.set(ALL_MODES, "<C-n>", "tab_next")
glide.keymaps.set(ALL_MODES, "<C-s>", "tab_close")
glide.keymaps.set(VIM_CONTROL, "<S-left>", "back")
glide.keymaps.set(VIM_CONTROL, "<S-right>", "forward")

glide.keymaps.set(ALL_MODES, "<C-w><C-n>", "tab_new")
glide.keymaps.set(ALL_MODES, "<C-w>n", "tab_new")
glide.keymaps.set(ALL_MODES, "<C-w><C-left>", removeTabs((tab, active_tab) => tab < active_tab))
glide.keymaps.set(ALL_MODES, "<C-w>left", removeTabs((tab, active_tab) => tab < active_tab))
glide.keymaps.set(ALL_MODES, "<C-w><C-right>", removeTabs((tab, active_tab) => tab > active_tab))
glide.keymaps.set(ALL_MODES, "<C-w>right", removeTabs((tab, active_tab) => tab > active_tab))
glide.keymaps.set(ALL_MODES, "<C-w><C-up>", removeTabs((tab, active_tab) => tab !== active_tab))

// Get the active Tab
async function activeTab(): Promise<Browser.Tabs.Tab>  {
  // SAFETY: The return value cannot be "undefined", because there is always 1 active tab
  return ((await browser.tabs.query({ active: true, currentWindow: true }))[0]) as Browser.Tabs.Tab;
}

// Remove tabs that satisfy the predicate
function removeTabs(predicate: (tab: number, active_tab: number) => boolean) {
  return async () => {
    const tabs = await browser.tabs.query({ pinned: false, currentWindow: true })
    const active_Tab = await activeTab()
    if (!activeTab) {
      return
    }
    const ids = tabs.filter(tab => predicate(tab.index, active_Tab.index)).map(tab => tab.id).filter(id => id !== undefined)
    browser.tabs.remove(ids)
  }
}

function opener(
  newtab: boolean,
): (props: glide.ExcmdCallbackProps) => void | Promise<void> {
  // ref: https://github.com/glide-browser/glide/discussions/61#discussioncomment-14672404
  function args_to_url(args: string[]): string | undefined {
    if (!args.length) return;

    // A single argument with dots is a host or URL on its own.
    // But take care to complete it with a scheme if it doesn't have one.
    if (args.length === 1 && args[0]!.indexOf(".") >= 0) {
      return /^[a-z]+:/.test(args[0]!) ? args[0]! : "https://" + args[0]!;
    }

    // Otherwise, consider the first argument as a search shorthand.
    for (const [shorthand, url] of Object.entries(search_engines)) {
      if (args[0]! === shorthand) {
        args.shift(); // drop shorthand
        const query = args.map(encodeURIComponent).join("+");
        return url.replace("{}", query);
      }
    }

    // No shorthand match. Feed all args to the default search engine.
    const query = args.map(encodeURIComponent).join("+");
    return default_search_engine.replace("{}", query);
  }

  return (props) => {
    const url = args_to_url(props.args_arr);
    if (url) {
      if (newtab) {
        browser.tabs.create({ url });
      } else {
        browser.tabs.update({ url });
      }
    }
  };
}

// Selects which function to call depending on whether we are editing or not
function edit_select(
  called_if_editing: glide.ExcmdString | glide.KeymapCallback | null,
  called_if_not_editing: glide.ExcmdString | glide.KeymapCallback | null,
): glide.KeymapCallback {
  return async (props) => {
    const action = (await glide.ctx.is_editing())
      ? called_if_editing
      : called_if_not_editing;

    if (!action) return;

    if (typeof action === "string") {
      await glide.excmds.execute(action);
    } else {
      action(props);
    }
  };
}

// store tab indices before pinning to restore position when unpinning
const tab_indices_before_pin = new Map<number, number>();
browser.tabs.onRemoved.addListener((tabId) => {
  tab_indices_before_pin.delete(tabId);
});
browser.tabs.onDetached.addListener((tabId) => {
  tab_indices_before_pin.delete(tabId);
});
glide.keymaps.set(ALL_MODES, "<C-w><C-p>", async ({ tab_id }) => {
  const tab = await browser.tabs.get(tab_id);
  if (tab.pinned) {
    const orig_idx = tab_indices_before_pin.get(tab_id);
    await browser.tabs.update(tab_id, { pinned: false });
    if (orig_idx !== undefined) {
      await browser.tabs.move(tab_id, { index: orig_idx });
    }
    tab_indices_before_pin.delete(tab_id);
  } else {
    tab_indices_before_pin.set(tab_id, tab.index);
    await browser.tabs.update(tab_id, { pinned: true });
  }
});

// Open URL in current tab
glide.excmds.create({ name: "open" }, opener(false));

// Open URL in new tab
glide.excmds.create({ name: "tab_open" }, opener(true));
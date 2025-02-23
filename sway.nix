{
  wayland.windowManager.sway = {
    enable = true;
    # fixes common issues with GTK3 apps: https://wiki.nixos.org/wiki/Sway
    wrapperFeatures.gtk = true;
    config = {
      window.titlebar = false;
      floating.titlebar = false;
      focus.wrapping = "no";
      window.hideEdgeBorders = "smart";
      # disable title bar https://github.com/swaywm/sway/issues/6946#issuecomment-1182012140
      fonts = {
        names = [ "monospace" ];
        size = 0.001;
      };
      bars = [ ];
      # gaps = {
      # left = 880;
      #   right = 440;
      # };
      keybindings = {
        "XF86AudioRaiseVolume" = "exec --no-startup-id pamixer --increase 5";
        "XF86AudioLowerVolume" = "exec --no-startup-id pamixer --decrease 5";
        "XF86AudioMute" = "exec --no-startup-id pamixer --toggle-mute";
        "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 5%-";
        "Mod1+k" = "exec grim -g \"$(slurp -d)\" - | wl-copy";
        "Mod1+m" = "exec wezterm-gui";
        "Mod1+r" = "exec firefox";
        "Mod1+t" = "kill";
        "Mod1+n" = "focus left";
        "Mod1+e" = "focus up";
        "Mod1+i" = "focus down";
        "Mod1+o" = "focus right";
        "Mod1+z" = "sticky toggle";
        "Mod1+2" = "move left";
        "Mod1+4" = "move down";
        "Mod1+1" = "move up";
        "Mod1+8" = "move right";
        "Mod1+g" = "floating toggle";
        "Mod1+w" = "workspace number 1";
        "Mod1+f" = "workspace number 2";
        "Mod1+p" = "workspace number 3";
        "Mod1+b" = "workspace number 4";
        "Mod1+5" = "move container to workspace number 1";
        "Mod1+0" = "move container to workspace number 2";
        "Mod1+3" = "move container to workspace number 3";
        "Mod1+7" = "move container to workspace number 4";
        "Mod1+j" = "resize grow width 10 px or 10 ppt";
        "Mod1+l" = "resize shrink width 10 px or 10 ppt";
        "Mod1+u" = "resize grow height 10 px or 10 ppt";
        "Mod1+y" = "resize shrink height 10 px or 10 ppt";
      };
      colors = {
        focused = {
          background = "#1e1e2e";
          border = "#cba6f7";
          childBorder = "#cba6f7";
          indicator = "#f5e0dc";
          text = "#cdd6f4";
        };
        focusedInactive = {
          background = "#1e1e2e";
          border = "#181825";
          childBorder = "#181825";
          indicator = "#f5e0dc";
          text = "#cdd6f4";
        };
        unfocused = {
          background = "#1e1e2e";
          border = "#181825";
          childBorder = "#181825";
          indicator = "#f5e0dc";
          text = "#cdd6f4";
        };
        urgent = {
          background = "#1e1e2e";
          border = "#fab387";
          childBorder = "#fab387";
          indicator = "#6c7086";
          text = "#fab387";
        };
        placeholder = {
          background = "#1e1e2e";
          border = "#181825";
          childBorder = "#181825";
          indicator = "#f5e0dc";
          text = "#cdd6f4";
        };
        background = "#1e1e2e";
      };
    };
    extraConfig = ''
      input type:keyboard {
        repeat_delay 200
        repeat_rate 50
      }
    '';
  };
  # use startx (^which i3) to run
  # Disable i3 config for now, but can still use it when I want to.
  # xsession.windowManager.i3 = {
  #   enable = true;
  #   inherit config;
  # };
  #
  # Also add this in configuration.nix:
  #
  # xserver = {
  #   enable = true;
  #   displayManager.startx.enable = true;
  #   windowManager.i3 = {
  #     enable = true;
  #   };
  #   autoRepeatDelay = 200;
  #   autoRepeatInterval = 25;
  #   xkb.layout = "us";
  # };
}

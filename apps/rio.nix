{ pkgs, ... }:
{
  programs.rio = {
    enable = true;
    package = pkgs.u.rio;
    settings = {
      bindings = {
        keys = [
          {
            action = "SelectNextTab";
            key = "n";
            "with" = "control";
          }
          {
            action = "SelectPrevTab";
            key = "p";
            "with" = "control";
          }
          {
            action = "ScrollHalfPageDown";
            key = "d";
            "with" = "alt";
          }
          {
            action = "ScrollHalfPageUp";
            key = "u";
            "with" = "alt";
          }
          {
            action = "CloseTab";
            key = "x";
            "with" = "control | shift";
          }
          {
            action = "IncreaseFontSize";
            key = "=";
            "with" = "control | shift";
          }
          {
            action = "DecreaseFontSize";
            key = "-";
            "with" = "control";
          }
          {
            action = "SearchForward";
            key = "f";
            "with" = "control | shift";
          }
          {
            action = "SearchBackward";
            key = "b";
            "with" = "control | shift";
          }
          {
            action = "ResetFontSize";
            key = "=";
            "with" = "control";
          }
          {
            action = "ToggleFullScreen";
            key = "F11";
          }
          {
            action = "ToggleVIMode";
            key = "\\";
            "with" = "control";
          }
          {
            bytes = [ 23 ];
            key = "back";
            "with" = "control";
          }
          {
            bytes = [
              27
              100
            ];
            key = "back";
            "with" = "shift";
          }
          {
            bytes = [ 11 ];
            key = "back";
            "with" = "control | shift";
          }
          {
            bytes = [ 21 ];
            key = "back";
            "with" = "shift | control";
          }
        ];
      };
      colors = {
        background = "#1e1e2e";
        black = "#45475a";
        blue = "#89b4fa";
        cursor = "#f5e0dc";
        cyan = "#94e2d5";
        dim-black = "#45475a";
        dim-blue = "#89b4fa";
        dim-cyan = "#94e2d5";
        dim-foreground = "#cdd6f4";
        dim-green = "#a6e3a1";
        dim-magenta = "#f5c2e7";
        dim-red = "#f38ba8";
        dim-white = "#bac2de";
        dim-yellow = "#f9e2af";
        foreground = "#cdd6f4";
        green = "#a6e3a1";
        light-black = "#585b70";
        light-blue = "#89b4fa";
        light-cyan = "#94e2d5";
        light-foreground = "#cdd6f4";
        light-green = "#a6e3a1";
        light-magenta = "#f5c2e7";
        light-red = "#f38ba8";
        light-white = "#a6adc8";
        light-yellow = "#f9e2af";
        magenta = "#f5c2e7";
        red = "#f38ba8";
        selection-background = "#f5e0dc";
        selection-foreground = "#1e1e2e";
        tabs = "#b4Befe";
        tabs-active = "#b4befe";
        vi-cursor = "#f5e0dc";
        white = "#bac2de";
        yellow = "#f9e2af";
      };
      confirm-before-quit = false;
      fonts = {
        bold = {
          family = "JetBrainsMono NF";
        };
        bold-italic = {
          family = "JetBrainsMono NF";
        };
        italic = {
          family = "JetBrainsMono NF";
        };
        regular = {
          family = "JetBrainsMono NF";
        };
        size = 23;
      };
      navigation = {
        use-current-path = true;
      };
      use-fork = false;
    };
  };
}

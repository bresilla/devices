{ ... }:
let
  # The 1600x2560 panel is mounted portrait; turn it to landscape and keep touch and
  # the pen on the same output and rotation.
  landscape = ''
    hl.monitor({ output = "DSI-1", mode = "preferred", position = "auto", transform = 3 })
    hl.config({ input = { touchdevice = { output = "DSI-1", transform = 3 }, tablet = { output = "DSI-1", transform = 3 } } })
  '';
in
{
  programs.eva.uiScale = 1.5;
  # The greeter runs its own Hyprland configuration.
  programs.eva.hyprland.extraConfig = landscape;
  programs.eva.greeter.extraConfig = landscape;
}

{ ... }:
let
  # The 1600x2560 panel is mounted portrait; turn it to landscape and keep touch and
  # the pen on the same output and rotation.
  landscape = ''
    hl.monitor({ output = "DSI-1", mode = "1600x2560@60", position = "auto", transform = 3 })
    hl.config({ input = { touchdevice = { output = "DSI-1", transform = 3 }, tablet = { output = "DSI-1", transform = 3 } } })
  '';
in
{
  programs.eva.uiScale = 1.5;
  # The greeter runs its own Hyprland configuration.
  programs.eva.hyprland.extraConfig = landscape;
  programs.eva.greeter.extraConfig = landscape;
  # Steam sizes its UI from the internal resolution; render it at the panel's own.
  bresilla.programs.steamArm64.session.gamescopeArgs = [
    "--force-orientation" "right"
    "-w" "2560" "-h" "1600"
    # Steam never sets its touch mode here, so touch stays touch instead of a pointer.
    "--default-touch-mode" "4"
    # 60 Hz rather than the preferred 120 Hz.
    "-r" "60"
  ];
  # Steam treats the EDID-less panel as an external screen; 2 gives the Deck's 800p layout.
  bresilla.programs.steamArm64.session.uiScale = "2";
}

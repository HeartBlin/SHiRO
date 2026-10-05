{ pkgs, ... }:

{
  environment = {
    systemPackages = [ pkgs.mangohud ];
    sessionVariables.MANGOHUD = 1;
  };
  hjem.users.primaryUser.files.".config/MangoHud/MangoHud.conf".text = ''
    fps_limit=141
    toggle_hud=Shift_R+F9

    # Panel Looks
    legacy_layout=0
    horizontal
    horizontal_stretch=0
    position=top-center
    hud_no_margin
    table_columns=1
    background_alpha=0.4
    font_size=18

    # Clock
    time
    time_no_label

    # FPS
    fps
    fps_color_change
    frametime

    # CPU
    cpu_load_change
    cpu_stats
    cpu_temp
    cpu_mhz

    # GPU
    pci_dev=0000:01:00.0
    gpu_load_change
    gpu_stats
    gpu_temp
    gpu_power

    # Memories
    ram
    vram
    swap
  '';
}

# Audio configuration with PipeWire
{ ... }:
{
  # Disable PulseAudio (using new location)
  services.pulseaudio.enable = false;

  # Enable PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}

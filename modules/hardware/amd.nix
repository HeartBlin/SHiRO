{
  boot.kernelParams = [ "amd_pstate=active" ];
  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
}

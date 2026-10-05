{
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      # No more than 10!
      ## Nothing to hide (4) - Netherlands
      "1.nts.nothingtohide.nl"
      "2.nts.nothingtohide.nl"
      "3.nts.nothingtohide.nl"
      "4.nts.nothingtohide.nl"

      ## PTB (4) - Germany
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
      "ptbtime4.ptb.de"

      ## Netnon (1) - Sweden
      "nts.netnod.se"
    ];
  };
}

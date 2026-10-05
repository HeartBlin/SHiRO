{
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      commit.gpgSign = true;
      gpg.format = "ssh";
    };
  };
}

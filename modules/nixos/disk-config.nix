_: {
  # This formats the disk with the ext4 filesystem
  # Other examples found here: https://github.com/nix-community/disko/tree/master/example
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/59759061-0e1c-4a7e-9d3a-899aac9b3959";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/40D8-098D";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e730cfd0-bd04-4760-92e2-e467011baf46"; }
    ];
}

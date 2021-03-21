{ pkgs, config, ... }:
{
  boot = {
    initrd.kernelModules = [];
    kernelParams = []; # Handled by U-Boot.
    kernelModules = [];
    kernelPackages = pkgs.linuxPackages;
    loader = {
      grub.enable = false;
      generationsDir = {
        enable = true;
        copyKernels = true;
      };
    };
  };
  sound.enable = false;
  services = {
    nixosManual.enable = false;
  };
  fileSystems = [
    { mountPoint = "/";
      device = "/dev/mmcblk0p3";
      options = "relatime";
      }
    { mountPoint = "/boot";
      device = "/dev/mmcblk0p1";
      neededForBoot = true;
      }
    ];
  swapDevices = [ { device = "/dev/mmcblk0p2"; } ];
  };
  nixpkgs.config = {
    platform = pkgs.platforms.sheevaplug;
  };
}
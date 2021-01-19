{ config, pkgs, options, ... }:
let
  # Build our photostrip package
  photostrip = pkgs.callPackage ./src {
    buildPythonPackage = pkgs.python38Packages.buildPythonPackage;
    pythonPackages = pkgs.python38Packages;
  };
in
{
  # Open HTTP/HTTPS ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Create a user for our service (not currently used)
  users.users.photostrip = {
    isNormalUser = true;
  };

  # Enable ACME for getting an SSL cert
  security.acme = {
    acceptTerms = true;
    email = "danielwilsonthomas@gmail.com";
  };

  # Setup NGinX for serving an SSL UWSGI app at photostrip.danielwilsonthomas.com.
  # The timeout for the UWSGI app is increased because generating images is expensive.
  services.nginx = {
    enable = true;
    virtualHosts = {
      "photostrip.danielwilsonthomas.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          extraConfig = ''
            include ${pkgs.nginx}/conf/uwsgi_params;
            uwsgi_pass unix:/run/nginx/photostrip.sock;
            uwsgi_read_timeout 300s;
          '';
        };
      };
    };
  };

  # Start up UWSGI with a single instance to run the photostrip app.
  # Note the socket lives in the /run/nginx folder so we run UWSGI as the nginx user.
  # Some environment variables are also set to force using the EBS tempdir.
  services.uwsgi = {
    enable = true;
    user = "nginx";
    group = "nginx";
    plugins = [ "python3" ];
    instance = {
      type = "normal";
      pythonPackages = ps: with ps; [ photostrip ];
      socket = "/run/nginx/photostrip.sock";
      wsgi = "photostrip:app";
      master = true;
      processes = 5;
      chmod-socket = 660;
      vacuum = true;
      die-on-term = true;
      env = [
        "MAGICK_TEMPORARY_PATH=/tmp/photostrip"
        "TMPDIR=/tmp/photostrip"
      ];
    };
  };

  system.stateVersion = "20.09";
}

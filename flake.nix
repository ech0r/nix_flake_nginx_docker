{
  description = "An nginx flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      # Replace this with your local binary path
      localBinary = ./hello_world/bin/Release/net7.0/publish;
    in
    pkgs.dockerTools.buildImage {
      name = "dotnet_nix";
      tag = "latest";
      copyToRoot = [ 
        pkgs.bashInteractive
        pkgs.coreutils-full
        pkgs.nginx 
        pkgs.shadow
        pkgs.shadow
      ];
      runAsRoot = ''
        #!${pkgs.runtimeShell}
        echo 'root:x:0:0:root:/root/bin/sh' > /etc/passwd
        echo 'root:x:0:' > /etc/group
        echo 'nobody:x:65534:65534:nobody:/:' >> /etc/passwd
        echo 'nogroup:x:65534:' >> /etc/group
        groupadd -g 101 nginx || true
        useradd -u 101 -g nginx -s /bin/sh -d /var/cache/nginx nginx || true
        mkdir -p /var/log/nginx
        touch /var/log/nginx/error.log
        chown -R nginx:nginx /var/log/nginx
        mkdir -p /run/nginx
        chown nginx:nginx /run/nginx
        cp ${./nginx.conf}  /conf/nginx.conf
        cp ${./mime.types}  /conf/mime.types
        cp -r ${./static}/* /html
      '';
      config = {
        Cmd = [ "${pkgs.nginx}/bin/nginx" "-c" "/conf/nginx.conf" "-g" "daemon off;" ];
        # Cmd = [ "tail" "-f" "/dev/null" ];
        ExposedPorts = {
          "80/tcp" = {};
        };
      };
    };
  };
}

{
  description = "A simple hello world application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        image = pkgs.dockerTools.buildImage {
          name = "nginx";
          tag = "latest";  
          copyToRoot = [ 
            pkgs.nginx 
            pkgs.shadow
          ];
          config = {
            Cmd = [ "${pkgs.nginx}/bin/nginx" "-c" "/conf/nginx.conf" "-g" "daemon off;" ];
            exposedPorts = {
              "80/tcp" = {};
            };
            User = "root";
          };
          runAsRoot = ''
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
        };
      in
      {
        packages.default = image;
        defaultPackage = image;
        dockerImage = image;
        dockerTarball = pkgs.dockerTools.exportImage {
          name = image;
          outputFile = "${image.name}.tar.gz";
        };
      }
    );
}

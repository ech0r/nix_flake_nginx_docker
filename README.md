1. clone repo 
2. run `nix build`
3. run `docker load < result`
4. run `docker run -p 8080:80 -d nginx:latest`
5. browse to http://localhost:8080

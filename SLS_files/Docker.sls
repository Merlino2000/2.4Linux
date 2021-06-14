apt install -y  docker.io:
  cmd.run
systemctl enable --now docker:
  cmd.run
sudo docker volume create --name storage:
  cmd.run
docker run -d --name filserver -v storag:/web -p 8080:8080 halverneus/static-file-server:latest:
  cmd.run

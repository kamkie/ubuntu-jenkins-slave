if [ $# -eq 0 ]; then
  echo "No arguments supplied - tail -f /var/log/podman.log"
  podman info >/var/log/podman.log

  tail -f /var/log/podman.log
fi

echo "executing passed command"

exec "$@"

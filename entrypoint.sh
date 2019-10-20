if [ $# -eq 0 ]; then
  echo "No arguments supplied - tail -f /var/log/podman.log"
  podman info > /tmp/podman.log

  tail -f /tmp/podman.log
fi

echo "executing passed command"

exec "$@"

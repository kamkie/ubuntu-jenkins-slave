sudo iptables-compat -nvL -t nat
sudo ./nft-fix

if [ $# -eq 0 ]; then
  echo "No arguments supplied - tail -f /var/log/podman.log"

  sudo -b dockerd -H unix:///var/run/docker.sock -H tcp://127.0.0.1:2375

  mkdir -p "${JENKINS_HOME}"
  cd "${JENKINS_HOME}"
  curl "${JENKINS_URL}jnlpJars/remoting.jar" -o remoting.jar
  java -cp remoting.jar hudson.remoting.jnlp.Main -headless -url "${JENKINS_URL}" -tunnel "${JENKINS_TUNNEL}" "${JENKINS_SECRET}" ${JENKINS_AGENT_NAME}
fi

echo "executing passed command"

exec "$@"

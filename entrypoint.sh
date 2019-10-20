if [ $# -eq 0 ]; then
  echo "No arguments supplied - tail -f /var/log/podman.log"

  sudo -b dockerd --iptables=false -H unix:///var/run/docker.sock -H tcp://127.0.0.1:2375

  mkdir -p "${JENKINS_AGENT_WORKDIR}"
  cd "${JENKINS_AGENT_WORKDIR}"
  curl "${JENKINS_URL}jnlpJars/agent.jar" -o agent.jar
  java -jar agent.jar -jnlpUrl "${JENKINS_URL}computer/slave/slave-agent.jnlp" -secret "${JENKINS_SECRET}" -workDir "${JENKINS_HOME}" -tunnel "${JENKINS_TUNNEL}"
fi

echo "executing passed command"

exec "$@"

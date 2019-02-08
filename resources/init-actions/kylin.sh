#!/bin/bash
#
# This initialization action installs Apache Kylin on Dataproc Cluster.

set -euxo pipefail

readonly KYLIN_VERSION=2.6.0
readonly KYLIN_FILE=apache-kylin-${KYLIN_VERSION}-bin
readonly KYLIN_URL="http://mirror.csclub.uwaterloo.ca/apache/kylin/apache-kylin-${KYLIN_VERSION}/apache-kylin-${KYLIN_VERSION}-bin-hbase1x.tar.gz"
readonly KYLIN_HOME='/etc/kylin'

function install_and_configure_kylin() {
  curl -o kylin.tar.gz ${KYLIN_URL}
  tar -zxf kylin.tar.gz
  mv  ${KYLIN_FILE} ${KYLIN_HOME}
  echo "export PATH=${KYLIN_HOME}/bin:\${PATH}" >> /etc/profile

  # TODO: remove once script is HA
  chmod -R 777 ${KYLIN_HOME}
}

# install
install_and_configure_kylin
# run
# TODO: HA-mode and bootable on init
# ${KYLIN_HOME}/bin/check-env.sh
# ${KYLIN_HOME}/bin/kylin.sh start

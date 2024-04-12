#!/bin/bash

# Exits when a command fails.
set -o errexit

# Use "strict mode with pipefail" (exit without continuing at first error).
set -o pipefail

# Prints every expression before executing it.
#set -o xtrace

export nifi_bootstrap_file=__INSTALL_DIR__/conf/bootstrap.conf
export nifi_props_file=__INSTALL_DIR__/conf/nifi.properties

# 1 - value to search for
# 2 - value to replace
# 3 - file to perform replacement inline
prop_replace () {
  target_file=${3:-${nifi_props_file}}
  echo "File [${target_file}] replacing [${1}]"
  /usr/bin/sed -i -e "s|^$1=.*$|$1=$2|"  ${target_file}
}

uncomment() {
  target_file=${2}
  echo "File [${target_file}] uncommenting [${1}]"
  /usr/bin/sed -i -e "s|^\#$1|$1|" ${target_file}
}

# Override JVM memory settings
if [ ! -z "${NIFI_JVM_HEAP_INIT}" ]; then
    prop_replace 'java.arg.2'       "-Xms${NIFI_JVM_HEAP_INIT}" ${nifi_bootstrap_file}
fi

if [ ! -z "${NIFI_JVM_HEAP_MAX}" ]; then
    prop_replace 'java.arg.3'       "-Xmx${NIFI_JVM_HEAP_MAX}" ${nifi_bootstrap_file}
fi

if [ ! -z "${NIFI_JVM_DEBUGGER}" ]; then
    uncomment "java.arg.debug" ${nifi_bootstrap_file}
fi


if [ -n "${NIFI_SENSITIVE_PROPS_KEY}" ]; then
    prop_replace 'nifi.sensitive.props.key' "${NIFI_SENSITIVE_PROPS_KEY}"
fi

./bin/nifi.sh start

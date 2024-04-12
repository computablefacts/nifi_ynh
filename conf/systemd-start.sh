#!/bin/bash

# Exits when a command fails.
set -o errexit

# Use "strict mode with pipefail" (exit without continuing at first error).
set -o pipefail

# Detects uninitialised variables in your script (and exits with an error).
set -o nounset

# Prints every expression before executing it.
#set -o xtrace

export nifi_props_file=__INSTALL_DIR__/conf/nifi.properties

# 1 - value to search for
# 2 - value to replace
# 3 - file to perform replacement inline
prop_replace () {
  target_file=${3:-${nifi_props_file}}
  echo "File [${target_file}] replacing [${1}]"
  /usr/bin/sed -i -e "s|^$1=.*$|$1=$2|"  ${target_file}
}

if [ -n "${NIFI_SENSITIVE_PROPS_KEY}" ]; then
    prop_replace 'nifi.sensitive.props.key' "${NIFI_SENSITIVE_PROPS_KEY}"
fi

./bin/nifi.sh start

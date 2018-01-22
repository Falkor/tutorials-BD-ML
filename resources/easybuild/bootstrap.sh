#! /bin/bash
################################################################################
# easybuild_install.sh - Install easybuild for the local user
# Time-stamp: <Mon 2018-01-22 09:45 svarrette>
################################################################################
# see also /etc/profile.d/easybuild.sh

EASYBUILD_PREFIX="${EASYBUILD_PREFIX:-$HOME/.local/easybuild}"
EASYBUILD_MODULES_TOOL="${EASYBUILD_MODULES_TOOL:-Lmod}"
EASYBUILD_MODULE_NAMING_SCHEME="${EASYBUILD_MODULE_NAMING_SCHEME:-CategorizedModuleNamingScheme}"

EB_INSTALL_SCRIPT='/tmp/bootstrap_eb.py'
EB_INSTALL_SCRIPT_URL='https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py'

# Fetch the installation script
if [ ! -f "${EB_INSTALL_SCRIPT}" ]; then
    curl -o ${EB_INSTALL_SCRIPT} ${EB_INSTALL_SCRIPT_URL}
fi

# Run it
if [ -n "${EASYBUILD_PREFIX}" ] &&  [ -f "${EB_INSTALL_SCRIPT}" ]; then
    EASYBUILD_MODULES_TOOL=${EASYBUILD_MODULES_TOOL} \
                          EASYBUILD_MODULE_NAMING_SCHEME=${EASYBUILD_MODULE_NAMING_SCHEME} \
                          python ${EB_INSTALL_SCRIPT} ${EASYBUILD_PREFIX}
fi

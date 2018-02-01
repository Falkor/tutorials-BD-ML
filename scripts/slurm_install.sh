#!/usr/bin/env bash
# Time-stamp: <Mon 2017-08-21 19:14 svarrette>
#################################################################################################
#     ____  _                      __      ____ __   ___           _        _ _
#    / ___|| |_   _ _ __ _ __ ___ | _|_/\_|  _ \_ | |_ _|_ __  ___| |_ __ _| | |
#    \___ \| | | | | '__| '_ ` _ \| |\    / | | | |  | || '_ \/ __| __/ _` | | |
#     ___) | | |_| | |  | | | | | | |/_  _\ |_| | |  | || | | \__ \ || (_| | | |
#    |____/|_|\__,_|_|  |_| |_| |_| |  \/ |____/| | |___|_| |_|___/\__\__,_|_|_|
#                                 |__|         |__|
#                     Copyright (c) 2017 UL HPC Team <hpc-sysadmins@uni.lu>
##################################################################################################
# Installation of a Slurm [Controller] Daemons
# Mainly targeting a deployment within on a CentoS 7 [Vagrant] Host
#
# Based on the installation notes and Vagrantfile of Valentin Plugaru <valentin.plugaru@uni.lu>
# Now adapted as a Puppet Module available on the forge -- see ULHPC/slurm 
#  - Github: https://github.com/ULHPC/puppet-slurm
#  - Forge:  https://forge.puppet.com/ULHPC/slurm
#
# Ensure this is the latest version (older releases may be downloaded from 
# https://github.com/SchedMD/slurm/releases  but tarball/unpacked version naming differs slightly)
SLURM_VERSION='17.02.7'

SETCOLOR_NORMAL=$(tput   sgr0)
SETCOLOR_TITLE=$(tput    setaf 6)   # Cyan
SETCOLOR_SUBTITLE=$(tput setaf 14)  #
SETCOLOR_RED=$(tput      setaf 1)
SETCOLOR_GREEN=$(tput    setaf 2)
SETCOLOR_BOLD=$(tput     setaf 15)
SETCOLOR_DEBUG=$(tput    setaf 3)   # Yellow

### Local variables
STARTDIR="$(pwd)"
SCRIPTFILENAME=$(basename $0)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERBOSE=''
DEBUG=''

# Which SLURM daemons to install
WITH_SLURMCTLD=''       # Controller
WITH_SLURMDBD=''        # Database
WITH_SLURMD='--slurmd'  # (Default) Regular daemon for frontend/compute nodes

# Slurm Configuration
SLURM_CLUSTERNAME=thor
SLURMD_CONFIG_FILES=(slurm.conf cgroup.conf gres.conf topology.conf plugstack.conf job_submit.lua)

# Shared directory hosting common files
VAGRANT_SHARED_DIR='/vagrant/vagrant'
# # Home base dir
# HOME_BASEDIR='/home/shared'
# RPMs Build directory
RPMs_BUILD_DIR='/root/rpmbuild/RPMS/x86_64'

# List of pre-requisite packages to install
PRE_REQUISITE_PACKAGES="epel-release vim screen htop wget mailx rng-tools rpm-build gcc gcc-c++ readline-devel openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad perl-devel perl-CPAN hdf5-devel.x86_64 lz4-devel freeipmi-devel hwloc-devel hwloc-plugins rrdtool-devel"
SLURMDB_BACKEND_PACKAGES="mariadb-server mariadb-devel"
MUNGE_PACKAGES="munge munge-libs munge-devel"

# Where to download slurm
SLURM_ARCHIVE="slurm-${SLURM_VERSION}.tar.bz2"
DOWNLOAD_URL="https://www.schedmd.com/downloads/latest/${SLURM_ARCHIVE}"

# Munge/Slurm System Configuration
MUNGE_GID=991
SLURM_GID=992


###############################################################################################
######
# Print information
##
info () {
    echo " "
    echo "${SETCOLOR_BOLD}${SETCOLOR_TITLE}$*${SETCOLOR_NORMAL}${SETCOLOR_NORMAL}"
}
error() {
    echo
    echo "${SETCOLOR_RED}*** ERROR *** $*${SETCOLOR_NORMAL}"
    exit 1
}
debug()   {
    [ -n "${DEBUG}" ] && echo "${SETCOLOR_NORMAL}${SETCOLOR_DEBUG} (Debug) ${SETCOLOR_NORMAL} $*"
}
print_usage() {
    cat <<EOF
    $0 [--debug] [--controller] [--clustername NAME]
    $0 [--debug] [--slurmctld] [--slurmdbd]
    $0 [--debug] [--slurmd]

Bootstrap SLURM Daemons version ${SLURM_VERSION}.
With --controller, both slurmctld and slurmdbd are built.

Based on the installation notes and guidelines of V. Plugaru.
EOF
}

###
# Install the packages passed as argument
# Usage:
#    pkg_install pkg1 [pkg2] [...]
##
pkg_install() {
    case $PACKAGE_TOOL in
        apt) apt-get install -y $*;;
        yum) yum install -y $*;;
        *)   error "Distribution Not detected/suported"
    esac
}
###
# As above, but perform a local installation of the provided rpms / debs
# Usage:
#    local_install file1.{rpm|deb} [file2.{rpm|deb} ...]
##
local_install() {
    debug "Local installation for the packages $*"
    case $PACKAGE_TOOL in
        apt) dpkg -i -y $*;;
        yum) yum -y --nogpgcheck localinstall $*;;
        *)   error "Distribution Not detected/suported"
    esac
}
###
# Start and Enable a service passed as parameter
# Usage:
#    service_restart  <name>
##
service_restart() {
    local name=$1
    case $PACKAGE_TOOL in
        apt)
            /etc/init.d/${name} restart;
            /etc/init.d/${name} status;
            ;;
        yum)  systemctl enable ${name};
              systemctl restart ${name};
              systemctl status ${name};;
        *)   error "Distribution Not detected/suported"
    esac

}

###
# Copy from vagrant [shared] configuration directory
##
vagrant_shared_restore() {
    local file=$1
    [ ! -d "/vagrant" ] && return
    [ ! -d "${VAGRANT_SHARED_DIR}" ] && error "No vagrant shared directory '${VAGRANT_SHARED_DIR}'"
    if [ -f "${VAGRANT_SHARED_DIR}/${file}" ]; then
        debug "copying ${VAGRANT_SHARED_DIR}/${file} into '${file}'"
        mkdir -p $(dirname ${file})
        cp ${VAGRANT_SHARED_DIR}/${file} ${file}
    fi
}
###
# Copy to vagrant [shared] configuration directory
##
vagrant_shared_backup() {
    local file=$1
    [ ! -d "/vagrant" ] && return
    [ ! -d "${VAGRANT_SHARED_DIR}" ] && error "No vagrant shared directory '${VAGRANT_SHARED_DIR}'"
    [ ! -f "${file}" ] && error "Non existing file '${file}'"
    # By default, do not overwrite the previously backup file
    if [ ! -f "${VAGRANT_SHARED_DIR}/${file}" ]; then
        debug "backuping ${file} into '${VAGRANT_SHARED_DIR}'"
        mkdir -p ${VAGRANT_SHARED_DIR}/$(dirname ${file})
        cp ${file} ${VAGRANT_SHARED_DIR}/${file}
    fi
}

###
# Build RPM Package for SLURM based on the archive passed as argument
# Usage:
#    rpmbuild_slurm '/path/to/slurm-<version>.tar.bz2'
##
rpmbuild_slurm() {
    local src_bz2=$1
    local vagrant_rpmdir="${VAGRANT_SHARED_DIR}/RPMs"
    local rpms=$( ls ${RPMs_BUILD_DIR}/slurm-*${SLURM_VERSION}*.rpm            2>/dev/null | xargs echo)
    local rpms_in_vagrant=$( ls ${vagrant_rpmdir}/slurm-*${SLURM_VERSION}*.rpm 2>/dev/null | xargs echo)

    [ ! -f "${src_bz2}" ] && error "Unable to find the SLURM sources '${src_bz2}'"

    # eventually restore previously generated RPMs from Vagrant
    if [[ -z "${rpms}" && -d "${vagrant_rpmdir}"  &&  -n "${rpms_in_vagrant}" ]]; then
        debug "restore the Slurm RPMs from ${vagrant_rpmdir}/ to ${RPMs_BUILD_DIR}/"
        mkdir -p ${RPMs_BUILD_DIR}
        cp ${vagrant_rpmdir}/slurm-*${SLURM_VERSION}*.rpm  ${RPMs_BUILD_DIR}/

    fi

    if [ -z "$( ls ${RPMs_BUILD_DIR}/slurm-*${SLURM_VERSION}*.rpm 2>/dev/null)" ]; then
        info "Generating SLURM RPMs from the source archive '${src_bz2}'"
        rpmbuild -ta --with lua ${src_bz2}
    fi

    if [ -d "${VAGRANT_SHARED_DIR}" ] && [ -z "${rpms_in_vagrant}" ]; then
        debug "backup the generated RPMs into '${vagrant_rpmdir}/'"
        mkdir -p ${vagrant_rpmdir}
        cp ${RPMs_BUILD_DIR}/slurm-*${SLURM_VERSION}*.rpm ${vagrant_rpmdir}/
    fi
}

###################  Slurm Component Bootstrapping function ######################
###
# Setup the Munge authentication service
##
setup_munge() {
    local munge_dir='/etc/munge'

    info "Setup Munge Authentication service"
    groupadd -g ${MUNGE_GID} munge # For MUNGE authentication service
    useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u ${MUNGE_GID} -g munge  -s /sbin/nologin munge
    pkg_install ${MUNGE_PACKAGES}

    vagrant_shared_restore "${munge_dir}/munge.key"

    if [ ! -f "${munge_dir}/munge.key" ]; then
        info "creating Munge key"
        rngd -r /dev/urandom
        /usr/sbin/create-munge-key -r
#        dd if=/dev/urandom bs=1 count=1024 > ${munge_dir}/munge.key
    fi
    chown munge: ${munge_dir}/munge.key
    chmod 400    ${munge_dir}/munge.key

    vagrant_shared_backup "${munge_dir}/munge.key"

    info "Starting the Munge service"
    service_restart munge

}

###
# Setup MariaDB backend for SlurmDBD
##
setup_mariadb() {
    info "Setup MariaDB backend for SlurmDBD"
    # normally not needed, yet reinstall the packages if needed
    pkg_install ${SLURMDB_BACKEND_PACKAGES}

    debug 'starting the MariaDB service'
    service_restart mariadb

    debug 'update DB internals'
    local mysql='mysql -s'    # --defaults-file=/root/.my.cnf
    mysql -s -e "UPDATE mysql.user SET Password = PASSWORD('rootpw') WHERE User = 'root'"  2>/dev/null
    #     if [ ! -f "/root/.my.cnf" ]; then
    #         cat << EOF > /root/.my.cnf
    # [mysql]
    #    user     = root
    #    host     = localhost
    #    password = rootpw
    # EOF
    #     fi
    ${mysql} -e "DROP USER ''@'localhost'"     2>/dev/null
    ${mysql} -e "DROP USER ''@'$(hostname)'"   2>/dev/null
    ${mysql} -e "DROP DATABASE test"           2>/dev/null
    ${mysql} -e "CREATE DATABASE slurm"        2>/dev/null
    ${mysql} -e "CREATE USER slurm"            2>/dev/null
    ${mysql} -e "GRANT ALL ON slurm.* TO 'slurm'@'localhost' IDENTIFIED BY 'slurmpw'"
    ${mysql} -e "FLUSH PRIVILEGES"
}

###
# Setup Slurm for this host
##
setup_slurm() {
    local src_slurm_archive_bz2="/usr/local/src/${SLURM_ARCHIVE}"
    local package_dir=${RPMs_BUILD_DIR}

    info "Setup SLURM"
    #__________________________________________
    debug "create user/group for SLURM daemons"
    groupadd -g ${SLURM_GID} slurm # For SLURM daemons
    useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u ${SLURM_GID} -g slurm  -s /bin/bash slurm

    #_____________ Download and build from sources ____________
    if [ ! -f "${src_slurm_archive_bz2}" ]; then
        debug "grabbing SLURM sources from '${DOWNLOAD_URL}'"
        wget -c ${DOWNLOAD_URL} -O ${src_slurm_archive_bz2}
    fi
    # TODO: deb versions ?
    rpmbuild_slurm ${src_slurm_archive_bz2}
    if [ -n "${WITH_SLURMCTLD}" ]; then
        pkgs=$(ls ${package_dir}/slurm-*${SLURM_VERSION}*.rpm  2>/dev/null | xargs echo)
    else
        pkgs=$(ls ${package_dir}/slurm-*${SLURM_VERSION}*.rpm  2>/dev/null | grep -vE '(sql|slurmdbd)' | xargs echo)
    fi
    [ -z "${pkgs}" ] && error "Unable o find the built packages for Slurm ${SLURM_VERSION} in '${package_dir}'"

    #____________________________________________________________
    info "Installing the SLURM packages built in ${package_dir}/"
    local_install $pkgs

    #_____________________________________________
    info "Adapt SLURM configuration under Vagrant"
    if [ -d '/vagrant' ]; then
        [ -n "${WITH_SLURMDBD}" ] && SLURMD_CONFIG_FILES+=(slurmdbd.conf)
        for f in "${SLURMD_CONFIG_FILES[@]}"; do
            debug "checking configuration file $f"
            if [[ -f "${VAGRANT_SHARED_DIR}/${f}" && ! -e "/etc/slurm/${f}" ]]; then
                debug "setting up /etc/slurm/${f} from ${VAGRANT_SHARED_DIR}"
                ln -s ${VAGRANT_SHARED_DIR}/${f} /etc/slurm/${f}
            fi
        done
    fi
    sleep 1
    #___________________________________________________________
    info "preparing directory structure for slurm system files"
    slurm_dirs=(/var/run/slurm /var/log/slurm)
    [ -n "${WITH_SLURMCTLD}" ] && slurm_dirs+=(/var/lib/slurmctld/)
    for d in ${slurm_dirs[@]}; do
        debug "preparing directory '${d}'"
        [ ! -d "$d" ] && mkdir -p ${d}
        chown -R slurm:slurm ${d}
    done
    slurm_files=(/var/log/slurm_jobacct.log  /var/run/slurmd.pid)
    [ -n "${WITH_SLURMCTLD}" ] && slurm_files+=(/var/run/slurmctld.pid  /var/lib/slurmctld/node_state  /var/lib/slurmctld/job_state)
    [ -n "${WITH_SLURMDBD}"  ] && slurm_files+=(/var/log/slurm/slurmdbd.log)
    for f in ${slurm_files[@]}; do
        debug "initiating system file ${f}"
        touch ${f}
        chown -R slurm:slurm ${f}
    done

    #_________________________________
    if [ -n "${WITH_SLURMDBD}" ]; then
        setup_mariadb
        service_restart slurmdbd
    fi
    [ -n "${WITH_SLURMCTLD}" ] && service_restart slurmctld
    [ -n "${WITH_SLURMD}"    ] && service_restart slurmd
}

###
# Setup PAM for slurmd
# See https://slurm.schedmd.com/faq.html#pam
##
setup_pam() {
    [ -z "${WITH_SLURMD}" ] && return
    local limits_conf="/etc/security/limits.conf"
    local src_pam="${VAGRANT_SHARED_DIR}/etc/pam.d/slurm"
    local dst_pam="/etc/pam.d/slurm"
    # PAM
    info "setup Pluggable Authentication Modules (PAM) for Slurm"
    if [ -n "${WITH_SLURMD}" ]; then
        debug "setup /etc/pam.d/slurm from '${src_pam}'"
        [ -f "${src_pam}" ] && [ ! -f "${dst_pam}" ] && ln -s ${src_pam} ${dst_pam}
    fi

    # Access
#     info "complete /etc/security/access.conf "
#     cat <<EOF >> /etc/security/access.conf

# EOF


    # Limits
    if [ -z "$(grep -E '^\*\s+hard\s+memlock\s+unlimited' ${limits_conf})" ]; then
        info "complete ${limits_conf}"
        cat << 'EOF' >> /etc/security/limits.conf
*   hard   memlock   unlimited
*   soft   memlock   unlimited
EOF
    fi
}

###
# Setup sample Slurm accounting
##
setup_slurm_accounting() {
    [ -z "${WITH_SLURMCTLD}" ] && return
    info "Add cluster '${SLURM_CLUSTERNAME}' in accounting database"
    sacctmgr -i add cluster ${SLURM_CLUSTERNAME}

    if [ -d '/vagrant' ]; then
        #info "remove 'normal' qos"
        #sacctmgr -i delete qos normal
        info "Add initial QOS and associations for testing"
        sacctmgr -i add account ALLUSERS Cluster=${SLURM_CLUSTERNAME} #QOS=ALL
        sacctmgr -i add account User.1   Parent=ALLUSERS Cluster=${SLURM_CLUSTERNAME}
        sacctmgr -i add account User.2   Parent=ALLUSERS Cluster=${SLURM_CLUSTERNAME}

        sacctmgr -i add user user1 DefaultAccount=User.1
        sacctmgr -i add user user2 DefaultAccount=User.2
        #_________
        # sacctmgr -i add qos qos-batch GrpNodes=1
        # sacctmgr -i add qos qos-batch-001 GrpNodes=2 flags=OverPartQOS
        # sacctmgr -i add account FSTC Cluster=${SLURM_CLUSTERNAME} QOS=qos-batch
        # sacctmgr -i add account Alexandre.Tkatchenko Parent=FSTC QOS=qos-batch-001 Cluster=${SLURM_CLUSTERNAME}
        # sacctmgr -i add account Pascal.Bouvry Parent=FSTC Cluster=${SLURM_CLUSTERNAME}
        # sacctmgr -i add user user1 DefaultAccount=Alexandre.Tkatchenko
        # sacctmgr -i add user user2 DefaultAccount=Pascal.Bouvry
    fi
    service_restart slurmctld
}


###
# Add testing users and group
##
vagrant_setup_testing_users_groups() {
    [ ! -d '/vagrant' ]     && return
    [ -z "${WITH_SLURMD}" ] && return
    local group='clusterusers'
    local gid=666
    local uid=5000
    local basedir="/home" #"${HOME_BASEDIR}"
    local user="user"
    local ssh_id_rsa='id_rsa_testing'
    [ ! -d "${basedir}" ] && basedir="/home"

    info "Add testing users and group"
    debug "setup group '${group}'"
    groupadd -g ${gid} ${group}
    usermod -G ${group} vagrant

    debug 'prepare a shared testing ssh key'
    install -o vagrant -g vagrant -m 600 ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa} ~vagrant/.ssh/${ssh_id_rsa}
    sudo -u vagrant cat ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa}.pub >> ~vagrant/.ssh/authorized_keys

    debug 'feeding /etc/skel/.ssh'
    mkdir -p /etc/skel/.ssh
    install -o root -g root -m 600 ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa} /etc/skel/.ssh/${ssh_id_rsa}
    cat ${VAGRANT_SHARED_DIR}/.ssh/${ssh_id_rsa}.pub >> /etc/skel/.ssh/authorized_keys

    # create two sample users
    for i in $(seq 1 2); do
        u="${user}$i"
        n=$(expr $uid + $i)
        debug "adding testing user '$u' with uid $n"
        useradd -b ${basedir} -u ${n} -g ${group} ${u} --create-home
    done
}




#######################  Per OS Bootstrapping function ##########################
setup_redhat() {
    info "Running yum update"
    yum update -y  >/dev/null

    info "Installing default packages"
    yum install -y epel-release
    yum install -y ${PRE_REQUISITE_PACKAGES} ${EXTRA_PACKAGES} >/dev/null

    if [ -n "${WITH_SLURMCTLD}" ]; then
        info "installing SLURMDBD backend (Maria DB)"
        yum install -y ${SLURMDB_BACKEND_PACKAGES}
    fi
    # Let's go
    setup_munge
    setup_slurm
    vagrant_setup_testing_users_groups
    setup_slurm_accounting
    setup_pam

    # Now final restart of all daemons
    [ -n "${WITH_SLURMDBD}" ]  && service_restart slurmdbd  || true
    [ -n "${WITH_SLURMCTLD}" ] && service_restart slurmctld || true
    [ -n "${WITH_SLURMD}"    ] && service_restart slurmd    || true
}

setup_apt() {
    case $1 in
        3*) codename=cumulus ;;
        6)  codename=squeeze ;;
        7)  codename=wheezy ;;
        8)  codename=jessie  ;;
        9)  codename=stretch  ;;
        12.04) codename=precise ;;
        14.04) codename=trusty  ;;
        16.04) codename=xenial ;;
        *) echo "Release not supported" ;;
    esac
    error "TODO -- NOT YET IMPLEMENTED"
}

###
# Detect Linux distribution and invoke the appropriate setup_* function
##
setup_linux() {
    ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
    if [ -f /etc/redhat-release ]; then
        OS=$(cat /etc/redhat-release | cut -d ' ' -f 1)
        majver=$(cat /etc/redhat-release | sed 's/[A-Za-z]*//g' | sed 's/ //g' | cut -d '.' -f 1)
    elif [ -f /etc/SuSE-release ]; then
        OS=sles
        majver=$(cat /etc/SuSE-release | grep VERSION | cut -d '=' -f 2 | tr -d '[:space:]')
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        majver=$VERSION_ID
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        majver=$(cat /etc/debian_version | cut -d '.' -f 1)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        majver=$DISTRIB_RELEASE
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        majver=$VERSION_ID
    else
        OS=$(uname -s)
        majver=$(uname -r)
    fi
    distro=$(echo $OS | tr '[:upper:]' '[:lower:]')
    info "Detected Linux distro: ${distro} version ${majver} on arch ${ARCH}"
    case "$distro" in
        debian|ubuntu)
            PACKAGE_TOOL='apt-get';
            setup_apt $majver ;;
        redhat|fedora|centos|scientific|amazon)
            PACKAGE_TOOL='yum'
            setup_redhat $majver ;;
        *) echo "Not supported distro: $distro"; exit 1;;
    esac

}

######################################################################################
[ $UID -gt 0 ] && error "You must be root to execute this script (current uid: $UID)"

# Parse the command-line options
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help)    print_usage;       exit 0;;
        -V | --version) print_version;     exit 0;;
        --debug)        DEBUG="--debug";;
        #-x | --extras)    shift; EXTRA_PACKAGES=$1;;
        -n | --clustername)
            shift;
            SLURM_CLUSTERNAME=$1;;
        -c | --controller)        # Wrapper for both DB and controller
            WITH_SLURMD='';
            WITH_SLURMCTLD=$1;
            WITH_SLURMDBD=$1;;
        --slurmctld)
            WITH_SLURMD='';
            WITH_SLURMCTLD=$1
            ;;
        --slurmdbd)
            WITH_SLURMD='';
            WITH_SLURMDBD=$1;;
        --slurmd)
            WITH_SLURMCTLD='';
            WITH_SLURMDBD='';
            WITH_SLURMD=$1;;
        # -b|--basedir|--homebasedir)
        #     shift;
        #     HOME_BASEDIR=$1;;
    esac
    shift
done

# Let's go
case "$OSTYPE" in
    linux*)   setup_linux ;;
    *)        echo "unknown: $OSTYPE"; exit 1;;
esac

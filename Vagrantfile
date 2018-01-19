# -*- mode: ruby -*-
# vi: set ft=ruby :
# Time-stamp: <Fri 2018-01-19 14:55 svarrette>
###########################################################################################
#             __     __                          _    __ _ _
#             \ \   / /_ _  __ _ _ __ __ _ _ __ | |_ / _(_) | ___
#              \ \ / / _` |/ _` | '__/ _` | '_ \| __| |_| | |/ _ \
#               \ V / (_| | (_| | | | (_| | | | | |_|  _| | |  __/
#                \_/ \__,_|\__, |_|  \__,_|_| |_|\__|_| |_|_|\___|
#                          |___/
###########################################################################################
require 'yaml'
require 'ipaddr'
require 'deep_merge'
require 'pp'
require 'erb'

###### Expected Vagrant plugins detection ######
# For more information on the below plugins:
# - https://github.com/oscar-stack/vagrant-hosts
# - https://github.com/dotless-de/vagrant-vbguest
# - https://github.com/emyl/vagrant-triggers
# - https://github.com/fgrehm/vagrant-cachier
# Terminal-table is a nice ruby gem for automatically print tables with nice layout
###
[ 'vagrant-hosts', 'vagrant-vbguest', 'vagrant-triggers', 'vagrant-cachier', 'terminal-table' ].each do |plugin|
  abort "Install the  '#{plugin}' plugin with 'vagrant plugin install #{plugin}'" unless Vagrant.has_plugin?("#{plugin}")
end
require 'terminal-table'

### Global variables ###
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Eventually a local YAML configuration for the deployment
TOP_SRCDIR  = File.expand_path File.dirname(__FILE__)
TOP_CONFDIR = File.join(TOP_SRCDIR, 'vagrant')
config_file = File.join(TOP_CONFDIR, 'config.yaml')

SHARED_DIR  = File.join('vagrant', 'shared')

### Default settings ###
DEFAULT_SETTINGS = {
  # Default images settings
  :defaults => {
    :os     => :centos7,
    :ram    => 512,
    :vcpus  => 2,
    :vbguest_auto_update => true,
    :nodes  => 1,
    :mode   => 'single',
  },
  # Default domain settings
  :network => {
    :domain => 'vagrant.dev',
    :range  => '10.10.1.0/24',
    :client_ip_start_offset => 100,
  },
  # Default Boxes
  :boxes => {
    :centos7  => 'centos/7',
    :debian8  => 'debian/contrib-jessie64',
    :ubuntu14 => 'ubuntu/trusty64'
  },
  # General Slurm Settings
  :slurm => {
    :template       => 'slurm.conf.erb',
    :clustername    => 'thor',
    :allowgroups    => 'clusterusers',
    # Default Partition / QoS. Format:
    # '<name>' => {
    #     :nodes   => n,           # Number of nodes
    #     :default => true|false,  # Default partition?
    #     :hidden  => true|false,  # Hidden partition?
    #     :allowgroups   => 'ALL|group[,group]*'
    #     :allowaccounts => 'ALL|acct[,acct]*'
    #     :allowqos      => 'ALL|qos[,qos]*'
    #     :state => 'UP|DOWN|DRAIN|INACTIVE'
    #     :oversubscribe => 'EXCLUSIVE|FORCE|YES|NO' (replace :shared)
    #     #=== Time: Format is minutes, minutes:seconds, hours:minutes:seconds, days-hours,
    #             days-hours:minutes, days-hours:minutes:seconds or "UNLIMITED"
    #     :default_time => 'UNLIMITED|DD-HH:MM:SS',
    #     :max_time     => 'UNLIMITED|DD-HH:MM:SS',
    #     #=== associated QoS config, named 'qos-<partition>' ===
    #     :priority => n           # QoS priority (default: 0)
    #     :preempt  => 'qos-<name>
    # }
    :partitions => {
      'interactive' => { :nodes => 1, :priority => 0,
                         :default_time => '0-10:00:00', :max_time => '5-00:00:00'  },
      # 'batch'       => { :nodes => 2, :priority => 100, :default => true, :preempt => 'qos-interactive',
      #                    :default_time => '0-2:00:00', :max_time => '5-00:00:00'},
      #'long'        => { :nodes => 1, :oversubscribe => 'FORCE', :allowqos => 'qos1,qos2' }
    },
    :accounts => {

    },
    ### General options you may wish to customize
    :mpidefault          => 'none',
    :mpiparams           => '',
    :topology            => '',
    :mempercpu           => 0,
    :maxmempercpu        => 0,
    :slurmctlddebug      => 3,
    :slurmddebug         => 3,
    :slurmctldport       => 6817,
    :slurmdport          => 6818,
    :srunportrange       => '50000-53000',
    :jobsubmitplugins    => '',    #'lua',
    #  job completion logging mechanism type. You can use 'jobcomp/mysql'
    :jobcomptype         => 'jobcomp/none',
    :jobcomploc          => '',
    # Health checker -- Ex: NHC / see https://github.com/mej/nhc
    :healthcheckprogram  => '',
    :healthcheckinterval => 30,
    # What level of association-based enforcement to impose on job submissions
    :acct_storageenforce => 'qos,limits,associations',
    # type of scheduler to be use
    :schedulertype       => 'sched/backfill',
    # Plugin used to identify which jobs can be preempted in order to start a pending job.
    :preempttype         => 'preempt/qos',
    :preemptmode         => 'requeue',
    # Plugin to be used in establishing a job's scheduling priority
    :prioritytype        => 'priority/multifactor',
    :prioritydecayHL     => '5-0',
    :priorityweightage       => 0,
    :priorityweightfairshare => 0,
    :priorityweightjobsize   => 0,
    :priorityweightpartition => 0,
    :priorityweightqos       => 0,
    # type of resource selection algorithm to be used
    :selecttype              => 'select/cons_res',
    :selecttype_params       => 'CR_Core_Memory,CR_CORE_DEFAULT_DIST_BLOCK',
    # type of task launch plugin, typically used to provide resource management within a node
    :taskplugin        => 'task/cgroup',
    :taskplugin_params => 'cpusets',
    # hooks
    :taskprolog => '',  # program to be execute prior to initiation of each task
    :taskepilog => '',  # program to be execute after termination of each task
  },
  # Characteristics of the virtual computing nodes within your cluster, from slurm point of view
  :nodes => {
    :cpus => 2,
    :sockets          => 1,
    :ram              => 512,
    :realmemory       => 400,
    :cores_per_socket => 2,
    :thread_per_core  => 1,
    :state            => 'UNKNOWN'
  },
  # virtual images to deploy
  # <name>:
  #   :hostname: <hostname>
  #   :desc: <VM-description>
  #   :os: <os>       # from the configured boxes
  #   :ram: <ram>
  #   :vcpus: <vcpus>
  #   :role: <role>   # supported: [ 'controller', 'frontend' ]

  :vms => {
    # IF in single mode, below is the definition of the box to deploy
    'default' => {
      :hostname => 'vm',
      :desc     => 'Testing Vagrant box',
    },
    # IF in cluster mode, below are the components to deploy
    # Slurm controller (primary)
    # /!\ SHOULD BE the first entry
    'slurm-master' => {
      :hostname => 'slurm1', :ram => 2048, :vcpus => 2, :desc => "Slurm Controller #1 (primary)",
      :role => 'controller'
    },
    'access' => {
      :hostname => 'access', :ram => 1024, :vcpus => 2, :desc => "Cluster frontend",
      :role => 'frontend'
    },
    # /!\ Computing nodes are added afterwards depending on the number of nodes / partitions to test.
  },
}

# List of default provisioning scripts
DEFAULT_PROVISIONING_SCRIPTS = [
  "vagrant/bootstrap.sh"
]

# Load the settings (eventually overwritten using values from the yaml file 'config/vagrant.yaml')
settings = DEFAULT_SETTINGS.clone
if File.exist?(config_file)
  config = YAML::load_file config_file
  #puts config.to_yaml
  settings.deep_merge!( config ) if config
end
#puts settings.to_yaml
# abort 'end'
#pp settings
abort "Undefined settings" if settings.nil?

############################################################
# Complete configuration of the boxes to deploy
defaults = settings[:defaults]
mode     = defaults[:mode]
if mode == 'cluster'
  settings[:vms].delete('default')
else
  # keep only the default entry
  settings[:vms].keep_if{|k,v| k == 'default'}
end
network  = settings[:network]
slurm    = settings[:slurm]
nodes    = settings[:nodes]

if mode == 'cluster'
  controller_vms = settings[:vms].select { |k,v| v[:role] == 'controller' }.values.first
  slurm[:controlmachine] = controller_vms[:hostname]
  frontend_vms = settings[:vms].select { |k,v| v[:role] == 'frontend' }.values.first
  slurm[:frontend] = frontend_vms[:hostname]

  # Complete settings with the appropriate number of computing nodes
  num_nodes = default_num_nodes = defaults[:nodes] ? defaults[:nodes] : 1
  if slurm[:partitions]
    num_partitions = slurm[:partitions].size
    sum_nodes_in_partition = slurm[:partitions].values.inject(0) { |sum, h| sum + h[:nodes]}
    num_nodes = [ default_num_nodes, sum_nodes_in_partition ].max
  end
  (1..num_nodes).each do |n|
    settings[:vms]["node#{n}"] = {
      :hostname => "#{slurm[:clustername]}-#{n}", :ram => nodes[:ram], :vcpus => nodes[:cpus], :desc => "Computing Node \##{n}"
    }
  end
end

############################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  ### Common configs shared by all VMs ###
  # Cache plugin -- Supports local cache, so you don't wast bandwitdh
  # vagrant plugin install vagrant-cachier   # see https://github.com/fgrehm/vagrant-cachier
  config.cache.auto_detect = true if Vagrant.has_plugin?("vagrant-cachier")

  # check if VirtualBox Guest Additions are up to date
  if Vagrant.has_plugin?("vagrant-vbguest")
    # set auto_update to false, if you do NOT want to check the correct
    # additions version when booting these boxes
    config.vbguest.auto_update = defaults[:vbguest_auto_update]
  end

  # # Specialize slurm.conf with the appropriate partitions and node names
  # erb        = File.join(TOP_CONFDIR, slurm[:template])
  # slurm_conf = File.join(TOP_CONFDIR, 'slurm.conf')
  # config.trigger.before :up do
  #   abort "Unable to find the ERB template for slurm.conf '#{erb}'" unless File.exists?( erb )
  #   if File.exists?(slurm_conf)
  #     puts "/!\\ WARNING: #{slurm_conf} already exists and won't be overwritten"
  #   else
  #     content = ERB.new(File.read(erb.to_s), nil, '<>').result(binding)
  #     puts "==> generating #{slurm_conf} from ERB template"
  #     File.open(slurm_conf.to_s, "w+") do |f|
  #       f.write content
  #     end
  #   end
  # end
  # # Delete slurm.conf AFTER destroy
  # config.trigger.after :destroy, :vm => /master/ do
  #   if File.exists?(slurm_conf)
  #     puts "/!\\ WARNING: #{slurm_conf} will be deleted"
  #     run "rm -f #{slurm_conf}"
  #   end
  # end


  # Shell provisioner, to bootstrap each box with the minimal settings/packages
  DEFAULT_PROVISIONING_SCRIPTS.each do |script|
    config.vm.provision "shell", path: "#{script}", keep_color: true
  end
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.synced_folder "vagrant/shared", "/shared", mount_options: ['dmode=777','fmode=777'],
                          type: "virtualbox" # Shared directory for users

  # network settings
  ipaddr   = IPAddr.new network[:range]
  ip_range = ipaddr.to_range.to_a
  ip_index = {
    :frontend     => 2,
    :controller   => 11,
    :node         => 101,
    :easybuild    => 1,
  }

  # cosmetics for the post-up message
  __table = {
    :title    => "Slurm Cluster deployed on Vagrant",
    :headings => [ 'Name', 'Hostname', 'OS', 'vCPU/RAM', 'Description', 'IP' ],
    :rows => [],
  }


  #__________________________________
  settings[:vms].each do |name, node|
    hostname = node[:hostname] ? node[:hostname] : name
    domain   = network[:domain]
    fqdn  =    "#{hostname}.#{domain}"
    os    =    node[:os]       ? node[:os].to_sym : defaults[:os].to_sym
    ram   =    node[:ram]      ? node[:ram]       : defaults[:ram]
    vcpus =    node[:vcpus]    ? node[:vcpus]     : defaults[:vcpus]
    role  =    node[:role]     ? node[:role]      : 'node'
    desc  =    node[:desc]     ? node[:desc]      : 'n/a'

    abort "Non-existing box OS '#{os}' for the VM '#{name}'" if  settings[:boxes][os.to_sym].nil?
    abort "Empty IP address range" if ip_range.empty?
    abort "Unknown role '#{role}' for the VM '#{name}'" unless ip_index[role.to_sym]
    ip = ip_range[ ip_index[role.to_sym].to_i ].to_s
    ip_index[role.to_sym] += 1   # increment index for the next VM of this type

    config.vm.define "#{name}" do |c|
      c.vm.box      = settings[:boxes][os.to_sym]
      c.vm.hostname = "#{fqdn}"
      c.vm.network :private_network, :ip => ip
      c.vm.provision :hosts, :sync_hosts => true

      c.vm.provider "virtualbox" do |v|
        v.customize [ 'modifyvm', :id, '--name', hostname, '--memory', ram.to_s ]
        v.customize [ 'modifyvm', :id, '--cpus', vcpus.to_s ] if vcpus.to_i > 1
        #v.customize [ 'setextradata', :id, 'VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root', '1']
      end
      c.vm.provision "shell", inline: "[ ! -h '/opt/apps' ] && ln -sf /vagrant/#{SHARED_DIR}/easybuild/#{os} /opt/apps || true"

      if mode == 'cluster'
        # Installation and setup of slurm
        c.vm.provision "shell" do |s|
          s.path = "scripts/slurm_install.sh"
          s.args = [ '--debug' ]
          if role == 'controller'
            s.args << "--clustername #{slurm[:clustername]}"
            s.args << '--controller'
          end
          s.keep_color = true
        end
        # Complete the QOS definition based on the configuration iff controller
        if role == 'controller'
          c.vm.provision "shell" do |s|
            s.inline = "echo '=> setup QOS based on partitions configuration'\n"
            slurm[:partitions].each do |p,v|
              priority = v[:priority] ? v[:priority] : 0
              saccrmgr_cmd = "sacctmgr -i add qos qos-#{p} Priority=#{priority} "
              saccrmgr_cmd << "Preempt=#{v[:preempt]} " if v[:preempt]
              saccrmgr_cmd << "GrpNodes=#{v[:nodes]} "
              saccrmgr_cmd << "flags=#{v[:flags]} "     if v[:flags]
              s.inline << "echo '    - running: #{saccrmgr_cmd}'\n"
              s.inline << "#{saccrmgr_cmd}\n"
            end
            # Alter the ALLUSERS account to allow the defined QoS
            global_account = "ALLUSERS"
            global_account_cmd = "sacctmgr -i modify account #{global_account} set QOS=qos-#{slurm[:partitions].keys.join(',qos-')}"
            s.inline << "echo '=> setup Slurm accounts'\n"
            s.inline << "echo '   - running: #{global_account_cmd}'\n"
            s.inline << "systemctl restart slurmctld"   # Expect to end with exit code 0
          end
        end
      end

    end
    __table[:rows] << [ name, fqdn, os.to_sym, "#{vcpus}/#{ram}", desc, ip]
  end

  config.trigger.after :up, :vm => "node#{num_nodes}"  do
    puts Terminal::Table.new __table
  end

end

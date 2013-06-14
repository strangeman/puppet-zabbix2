# == Class: zabbix2::client
#
# Данный класс предоставляет конфигурацию агента zabbix v2.x
#
# This class provide zabbix agent configuration 2.x version
#
# === Parameters
# [*zabbix_server*]
#   List of comma delimited IP addresses (or hostnames) of Zabbix servers.
# [*zabbix_server_active*]
#   List of comma delimited IP:port (or hostname:port) pairs of Zabbix servers for active checks. If port is not specified, default port is used.
# [*hostname*]
#   Unique, case sensitive hostname. Required for active checks and must match hostname as configured on the server.
# [*conf_pid_file*]
#   Name of PID file.
# [*conf_log_file*]
#   Name of log file. If not set, syslog is used.
# [*log_file_size*]
#   Maximum size of log file in MB. 0 - disable automatic log rotation.
# [*debug_level*]
#   Specifies debug level
# [*enable_remote_commands*]
#   Whether remote commands from Zabbix server are allowed.
# [*log_remote_commands*]
#   Enable logging of executed shell commands as warnings.
# [*listen_port*]
#   Agent will listen on this port for connections from the server.
# [*listen_ip*]
#   List of comma delimited IP addresses that the agent should listen on. First IP address is sent to Zabbix server if connecting to it to retrieve list of active checks.
# [*start_agents*]
#   Number of pre-forked instances of zabbix_agentd that process passive checks. If set to 0, disables passive checks and the agent will not listen on any TCP port.
# [*refresh_active_checks*]
#   How often list of active checks is refreshed, in seconds.
# [*buffer_send*]
#   Do not keep data longer than N seconds in buffer.
# [*buffer_size*]
#   Maximum number of values in a memory buffer. The agent will send all collected data to Zabbix Server or Proxy if the buffer is full.
# [*max_lines_per_second*]
#   Maximum number of new lines the agent will send per second to Zabbix Server or Proxy processing 'log' and 'logrt' active checks.
# [*allow_root*]
#   Allow the agent to run as 'root'. If disabled and the agent is started by 'root', the agent will try to switch to user 'zabbix' instead. Has no effect if started under a regular user.
# [*time_out*]
#   Spend no more than Timeout seconds on processing
# [*include_dir*]
#   You may include individual files or all files in a directory in the configuration file. Installing Zabbix will create include directory in /etc/zabbix, unless modified during the compile time.
# [*unsafe_user_parameters*]
#   Allow all characters to be passed in arguments to user-defined parameters.
# [*user_parameters*]
#   List of user-defined monitoring parameters.
#
# === Actions
# - добавляет репозитории с zabbix v2.x / add zabbix 2.x repos
# - устанавливает пакет zabbix-agent v2.x / install 'zabbix-agent' v2.x package
# - создает конфигурационный файл / create config file
# - запускает и контролирует демон zabbix-agent / run and control zabbix-agent daemon
#
# === Examples
#  class {'zabbix::client':
#    hostname => 'testtesttest',
#    user_parameters => ['mysql.ping,mysqladmin -uroot ping|grep alive|wc -l',
#                       'system.test,who|wc -l',
#                       'softraid.status,egrep \"\\[.*_.*\\]\" /proc/mdstat|wc -l']
#  }
# === Authors
# Anton Markelov <doublic@gmail.com> <markelovaa@dalstrazh.ru>
#
class zabbix2::client(
  $zabbix_server          = 'zabbix.localnet',
  $zabbix_server_active   = false,
  $hostname               = false,
  $listen_port            = '10050',
  $listen_ip              = false,
  $start_agents           = 5,
  $refresh_active_checks  = 120,
  $buffer_send            = 5,
  $buffer_size            = 100,
  $max_lines_per_second   = 100,
  $allow_root             = 0,
  $enable_remote_commands = 0,
  $log_remote_commands    = 0,
  $debug_level            = 3,
  $pid_file               = false,
  $log_file               = false,
  $log_file_size          = 1,
  $time_out               = 3,
  $unsafe_user_parameters = 0,
  $user_parameters        = false,
  $include_dirs           = false
  ) {

  if $hostname == false {
    fail('Module zabbix2: hostname parameter required!')
  }

  if $zabbix_server_active == false {
    $zabbix_server_active_name = $zabbix_server
  }
  else{
    $zabbix_server_active_name = $zabbix_server_active
  }

  if $pid_file == false {
    case $::lsbdistid {
      'debian': {
#        $conf_pid_file = '/var/run/zabbix-agent/zabbix_agentd.pid'
        $conf_pid_file = '/var/run/zabbix/zabbix_agentd.pid'
      }
      'ubuntu': {
        $conf_pid_file = '/var/run/zabbix/zabbix_agentd.pid'
      }
      default: {
        fail("Module zabbix is not supported on ${::operatingsystem}")
      }
    }
  }
  else {
    $conf_pid_file = $pid_file
  }

  if $log_file == false {
    case $::lsbdistid {
      'debian': {
        $conf_log_file = '/var/log/zabbix/zabbix_agentd.log'
      }
      'ubuntu': {
        $conf_log_file = '/var/log/zabbix-agent/zabbix_agentd.log'
      }
      default: {
        fail("Module zabbix2 is not supported on ${::operatingsystem}")
      }
    }
  }
  else {
    $conf_log_file = $log_file
  }

  require zabbix2::repo

  #install zabbix
  package{'zabbix-agent':
    ensure => latest,
  }

  file {'/etc/zabbix/zabbix_agentd.conf':
    content => template('zabbix2/zabbix_agentd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service {'zabbix-agent':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

  cron { 'restart_zabbix2':
    command  => "killall zabbix_agentd ; /etc/init.d/zabbix-agent stop ; /etc/init.d/zabbix-agent start",
    user     => root,
    hour     => '12',
    minute   => '0'
    }
  }

  File['/etc/zabbix/zabbix_agentd.conf']->Package['zabbix-agent']~>Service['zabbix-agent']
}
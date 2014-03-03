# Class: zabbix2::windows
#
#
class zabbix2::windows (
  $zabbix_server          = 'zabbix',
  $zabbix_server_active   = false,
  $hostname               = false,
  $listen_port            = '10050',
  $listen_ip              = false,
  $start_agents           = 5,
  $refresh_active_checks  = 120,
  $buffer_send            = 5,
  $buffer_size            = 100,
  $max_lines_per_second   = 100,
  $enable_remote_commands = 0,
  $log_remote_commands    = 0,
  $debug_level            = 3,
  $conf_log_file          = 'C:\Program Files\Zabbix Agent\Zabbix_agentd.log',
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

  file { 'c:/distrib/zabbix':
    ensure => 'directory',
  }

  file { 'c:/distrib/zabbix/zabbix_agent_x86.msi':
    ensure => 'file',
    source => 'puppet:///modules/zabbix2/zabbix_agent_x86.msi',
  }

  #install zabbix
  #[server=ZabbixServerIPAddress][lport=ListenPort] [serveractive=List IP:Port] [rmtcmd=1] [/qn]
  package{'Zabbix Agent':
    ensure => installed,
    source => 'c:/distrib/zabbix/zabbix_agent_x86.msi',
    source_permissions => ignore,
    install_options => ['server=zabbix', 'lport=10050', 'serveractive=zabbix:10051', 'rmtcmd=1', '/qn']
  }

  file {'C:/Program Files/Zabbix Agent':
    content => template('zabbix2/zabbix_agentd_win.conf.erb'),
    ensure  => 'file',
  }
  
  service {'Zabbix Agent':
    ensure     => running,
    enable     => true,
  }

  File['C:/Program Files/Zabbix Agent']~>Service['Zabbix Agent']
  File['C:/Program Files/Zabbix Agent']->Package['Zabbix Agent']~>Service['Zabbix Agent']

}
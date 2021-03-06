# Class: zabbix2::windows
#
#
#перечисляем основные параметры модуля. большинство из них потом 
#подставится в конфигурационный файл
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
  $include_dirs           = false,
  $version                = '2.4.0.0'
  ) {

  #проверяем заполнение обязательного параметра и формируем недостающие
  if $hostname == false {
    fail('Module zabbix2: hostname parameter required!')
  }

  if $zabbix_server_active == false {
    $zabbix_server_active_name = $zabbix_server
  }
  else{
    $zabbix_server_active_name = $zabbix_server_active
  }

  #создаем папку на сервере, в которую положим дистрибутив
  file { 'c:/distrib/zabbix':
    ensure => 'directory',
    source_permissions => ignore,
  }

  #http://www.suiviperf.com/zabbix/index.php
  #кладем в эту папку собственно дистрибутив нужной версии и архитектуры
  file { 'c:/distrib/zabbix/zabbix_agent.msi':
    ensure             => 'file',
    source             => "puppet:///modules/zabbix2/zabbix_agent_${::architecture}_${version}.msi",
    source_permissions => ignore,
  }  

  #устанавливаем zabbix из msi-пакета, подставляя опции
  #(которые, правда, нам все равно не нужны, т.к. мы будем потом
  # редактировать конфиг как нам надо)
  # #[server=ZabbixServerIPAddress][lport=ListenPort]
  # #[serveractive=List IP:Port] [rmtcmd=1] [/qn]
  package{'Zabbix Agent':
    ensure => $version,
    source => 'c:/distrib/zabbix/zabbix_agent.msi',
    #usually not needed, because we change config file after install
    install_options => ['server=zabbix',
                        'lport=10050', 'serveractive=zabbix:10051',
                        'rmtcmd=1', '/qn']
  }

  #создаем конфиг из шаблона 
  file {'C:/Program Files/Zabbix Agent/zabbix_agentd.conf':
    ensure             => 'file',
    content            => template('zabbix2/zabbix_agentd_win.conf.erb'),
    source_permissions => ignore,
  }

  #запускаем службу
  service {'Zabbix Agent':
    ensure     => running,
    enable     => true,
  }

  #настраиваем зависимости

  #любое изменение конфига должно вызывать рестарт сервиса
  File['C:/Program Files/Zabbix Agent/zabbix_agentd.conf']~>
  Service['Zabbix Agent']
  
  #сначала ставим пакет, а потом только редактируем конфиг
  #чтобы он не затерся версией из пакета
  Package['Zabbix Agent']->
  File['C:/Program Files/Zabbix Agent/zabbix_agentd.conf']

}
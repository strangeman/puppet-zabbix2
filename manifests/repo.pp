# == Class: zabbix2::repo
#
# Данный класс предоставляет настройку репозиториев zabbix 2 для debian 6/7 и
# ubuntu 12.04
#
# === Authors
# Anton Markelov <doublic@gmail.com> <markelov@kms.solnce.ru>
#
class zabbix2::repo (
  $version    = '2.2',
  $need_repo  = true,
  ) {

  $repo_key = '79EA5ED4'
  $repo_key_server = 'keys.gnupg.net'
  $repo_location = "http://repo.zabbix.com/zabbix/${version}/${::lsbdistid}/"

  if $need_repo == true {
    apt::key { 'zabbix2':
            key         => $repo_key,
            key_server  => $repo_key_server,
    }

    apt::source { 'zabbix2':
            location    => $repo_location,
            repos       => 'main contrib non-free',
            include_src => true
    }
  }
}

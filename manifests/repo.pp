# == Class: zabbix2::repo
#
# Данный класс предоставляет настройку репозиториев zabbix 2 для debian 6/7 и ubuntu 12.04
#
# === Authors
# Anton Markelov <doublic@gmail.com> <markelov@kms.solnce.ru>
#
class zabbix2::repo{
  #add repo and key
  case $::lsbdistid {
    'debian': {
      case $::lsbmajdistrelease {
        '6':{
          $need_repo = true
          $repo_location = "http://repo.zabbix.com/zabbix/2.0/debian/"
          $repo_key = "79EA5ED4"
          $repo_key_server = "keys.gnupg.net"
        }
        '7':{
          $need_repo = false
        }
      }
    }
    'ubuntu': {
      $need_repo = true
      $repo_location = "http://repo.zabbix.com/zabbix/2.0/ubuntu/"
      $repo_key = "79EA5ED4"
      $repo_key_server = "keys.gnupg.net"
    }
    default: {
      $need_repo = false
    }
  }

  if $need_repo == true {
    apt::key { "zabbix2":
            key         => $repo_key,
#            key_options => "http-proxy=\"http://markelovaa:123456789@192.168.0.232:3128\"",
            key_server  => $repo_key_server,
    }

    apt::source { "zabbix2":
            location    => $repo_location,
            repos       => "main",
            include_src => true
    }
  }
}

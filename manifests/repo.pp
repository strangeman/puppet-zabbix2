# == Class: zabbix2::repo
#
# Данный класс предоставляет настройку репозиториев zabbix 2 для debian 6/7 и
# ubuntu 12.04
#
# === Authors
# Anton Markelov <doublic@gmail.com> <markelov@kms.solnce.ru>
#
class zabbix2::repo (
  $version    = 'latest',
  $need_repo  = true,
  ) {

  $repo_key = '79EA5ED4'
  $repo_key_server = 'keys.gnupg.net'
  $downcase_lsbdistid = downcase($::lsbdistid)



  if $version == 'latest' {
    case $::lsbdistid {
      'debian': {
        case $::lsbmajdistrelease {
          '7': $repo_version = '2.4'
          default: $repo_version = '2.2'
        }
      }
      'ubuntu': {
        case $::lsbmajdistrelease {
          '14.04': $repo_version = '2.4'
          default: $repo_version = '2.2'
        }
      }
      default: {
        fail("Module zabbix is not supported on ${::operatingsystem}")
      }
    }
  }
  else {
    $repo_version = $version
  }

  $repo_location = "http://repo.zabbix.com/zabbix/${repo_version}/${downcase_lsbdistid}/"

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

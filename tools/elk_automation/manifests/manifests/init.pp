class kibana::base {
  group {
    "kibana": ensure => present,
  }
  user {
    "kibana":
      ensure => present,
      require => Group["kibana"],
      gid => "kibana";
  } 
  file {
    "/srv/app/kibana":
      ensure => directory,
      require => File["/srv/app"];
  }
}
 
class kibana::package_3 {
  include kibana::base
  package {
    "kibana":
      require => [ User["kibana"], File["/srv/app/kibana"] ],
      ensure => "3.0.0-1";
    "nginx12":
      ensure => latest;
  }
}

class kibana::package_4 {
  include kibana::base
  package {
    "kibana4":
      require => [ User["kibana"], File["/srv/app/kibana"] ],
      ensure => "4.0.1-1";
  }
}

class kibana::kibana_3 {
  include kibana::base
  include kibana::package_3

  file {
    "/srv/etc/kibana/config.js":
      ensure => file,
      source => "puppet:///modules/kibana/config.js";
    "/srv/etc/kibana/nginx.conf":
      ensure => file,
      source => "puppet:///modules/kibana/nginx.conf";
  }
  daemontools::service {
    "nginx-kibana":
      require => [Package["kibana"], Package["nginx12"]],
      runner => "puppet:///modules/kibana/run";
  }
}

class kibana::kibana_4 {
  include kibana::base
  include kibana::package_4
  if has_service("kibana-prod") {
    file {
      "/srv/etc/kibana":
        ensure => directory,
        require => File["/srv/etc"];
      "/srv/etc/kibana/kibana.yml":
        ensure => file,
        content => infradbfetch("/api/kibana/kibana.yml");
      "/srv/var/kibana":
        owner => "kibana",
        ensure => directory;
    } 
  }
  else {
    file {
      "/srv/etc/kibana":
        ensure => directory,
        require => File["/srv/etc"];
      "/srv/etc/kibana/kibana.yml":
        ensure => file,
        content => infradbfetch("/api/kibana/kibana_stage.yml");
      "/srv/var/kibana":
        owner => "kibana",
        ensure => directory;
    }
  }

  daemontools::service {
    "kibana4":
      require => [Package["kibana4"],File["/srv/etc/kibana/kibana.yml"]],
      subscribe => Package["kibana4"],
      runner => "puppet:///modules/kibana/service/run";
  }
}

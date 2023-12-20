# Define: dnsdist::newserver
#
#  Manages the backend servers of dnsdist
#
# Author
#   Michiel Piscaer <michiel@piscaer.com>
#
# Version
#   0.1   Initial release
#
# Parameters:
#   @param forward_address
#   @param pool
#   @param resolver_name
# Requires:
#
# Sample Usage:
#
#   dnsdist::newserver {
#     '192.168.2.1':
#       pool => 'local',
#       resolver_name = 'ns1';
#   }
#
define dnsdist::newserver (
  String $forward_address         = $title,
  Optional[String] $pool          = undef,
  Optional[String] $resolver_name = undef,
) {
  concat::fragment { "newserver-${pool}-${forward_address}":
    target  => '/etc/dnsdist/dnsdist.conf',
    content => template('dnsdist/concat_fragments/newserver.erb'),
    order   => '20',
  }
}


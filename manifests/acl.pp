# Define: dnsdist::acl
#
#  Manages the ACL of dnsdist
#
# Author
#   Michiel Piscaer <michiel@piscaer.com>
#
# Version
#   0.1   Initial release
#
# Parameters:
#   @param networkaddress
#
# Requires:
#
# Sample Usage:
#
#   dnsdist::acl { [
#     '192.168.1.0/24']:
#   }
#
define dnsdist::acl (
  String $networkaddress = $title,
) {
  concat::fragment { "acl-${title}":
    target  => '/etc/dnsdist/dnsdist.conf',
    content => template('dnsdist/concat_fragments/acl.erb'),
    order   => '45',
  }
}


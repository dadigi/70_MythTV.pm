#
#  70_MythTVBackend.pm 
#

package main;

use HttpUtils;
use MythAPI;
#use Data::Dumper;

sub MythTVBackend_Initialize($) {
  my ($hash) = @_;
  $hash->{DefFn}         = "MythTVBackend_Define";
# $hash->{UndefFn}       = "MythTVBackend_Undef";
# $hash->{DeleteFn}      = "MythTVBackend_Delete";
# $hash->{SetFn}         = "MythTVBackend_Set";
# $hash->{GetFn}         = "MythTVBackend_Get";
# $hash->{AttrFn}        = "MythTVBackend_Attr";
# $hash->{ReadFn}        = "MythTVBackend_Read";
# $hash->{ReadyFn}       = "MythTVBackend_Ready";
# $hash->{NotifyFn}      = "MythTVBackend_Notify";
# $hash->{RenameFn}      = "MythTVBackend_Rename";
# $hash->{ShutdownFn}    = "MythTVBackend_Shutdown"; 
  $hash->{AttrList} =
                      $readingFnAttributes;
}

sub MythTVBackend_Define($$) {
  my ($hash, $def) = @_;

  my @a = split("[ \t][ \t]*", $def);
  return "Usage: define <name> MythTVBackend hostname|ip-address[:port]" if(@a < 2);

  my $name = $a[0];
  $hash->{NAME} = $name;

  my ($host,$port);
     ($host,$port) = split( ':', $a[2] ) if( $a[2] );
  $hash->{host} = $host;
  $hash->{port} = $port?$port:6544;
  $hash->{backend} = $hash{host}.":".$hash{port};
  $hash->{NOTIFYDEV} = "global";
  
  return undef;  
}

sub MythTVBackend_getVersion(){
  my $mythAPI = MythAPI->new(server=>$hash{backend});
  my $data = $mythAPI->GetConnectionInfo();
  my $ret = $data->{Version}->{Version};

  return $ret;
}
1;


# Beginn der Commandref

=pod
=item [helper|device|command]
=item summary Connects to a MythTV backend DVR system via service API to query varoius status information.
=item summary_DE Verbindet sich zu einem MythTV Backend DVR System um verschiedene Statusinformationen abzufragen.

=begin html
 English Commandref in HTML
=end html

=begin html_DE
 Deutsche Commandref in HTML
=end html

# Ende der Commandref
=cut

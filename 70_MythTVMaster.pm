#
#  70_MythTVMaster.pm 
#

package main;

use HttpUtils;
use MythAPI;
#use Data::Dumper;

sub MythTVMaster_Initialize($) {
  my ($hash) = @_;
  $hash->{DefFn}         = "MythTVMaster_Define";
# $hash->{UndefFn}       = "MythTVMaster_Undef";
# $hash->{DeleteFn}      = "MythTVMaster_Delete";
# $hash->{SetFn}         = "MythTVMaster_Set";
# $hash->{GetFn}         = "MythTVMaster_Get";
# $hash->{AttrFn}        = "MythTVMaster_Attr";
# $hash->{ReadFn}        = "MythTVMaster_Read";
# $hash->{ReadyFn}       = "MythTVMaster_Ready";
# $hash->{NotifyFn}      = "MythTVMaster_Notify";
# $hash->{RenameFn}      = "MythTVMaster_Rename";
# $hash->{ShutdownFn}    = "MythTVMaster_Shutdown"; 
  $hash->{AttrList} =
                      $readingFnAttributes;
}

sub MythTVMaster_Define($$) {
  my ($hash, $def) = @_;

  my @a = split("[ \t][ \t]*", $def);
  return "Usage: define <name> MythTVMaster hostname|ip-address[:port]" if(@a < 2);

  my $name = $a[0];
  $hash->{NAME} = $name;

  my ($host,$port);
     ($host,$port) = split( ':', $a[2] ) if( $a[2] );
  $hash->{host} = $host;
  $hash->{port} = $port?$port:6544;

  $hash->{NOTIFYDEV} = "global";
  
  return undef;  
}

sub MythTVMaster_getVersion(){
  my $master = $hash{host}.":".$hash{port};
  my $mythAPI = MythAPI->new(server=>$master);
  my $data = $mythAPI->GetConnectionInfo();
  my $ret = $data->{Version}->{Version};

  return $ret;
}
1;


# Beginn der Commandref

=pod
=item [helper|device|command]
=item summary Connects to a MythTVMaster DVR system via service API to query varoius status information.
=item summary_DE Verbindet sich zu einem MythTVMaster DVR System um verschiedene Statusinformationen abzufragen.

=begin html
 Englische Commandref in HTML
=end html

=begin html_DE
 Deustche Commandref in HTML
=end html

# Ende der Commandref
=cut

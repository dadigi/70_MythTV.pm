# Module to connect to MythTV Service API
# created by Hoodlum7
# https://www.mythtv.org/wiki/Services_API_with_PERL
# Ugly hacks:
# Added current mythtv version and removed frontend service for backend-only system

package MythAPI;

use SOAP::Lite;
use strict;
use warnings;

#Version 1.00    24 April 2017 Initial version using WSDL.


sub new{
    my $class = shift;
    my %options = @_;
   
    #Define MythTV versions and Service classes for the version.
    #Actual supported methods are determined automatically. The list of Services are
    #available via Doxygen output of source code.  https://code.mythtv.org/doxygen/classService.html
    my %mythversion=(
        0.25    =>    ["Capture","Channel","Content","Dvr","Frontend","Guide","Myth","Video"],
        0.26    =>    ["Capture","Channel","Content","Dvr","Frontend","Guide","Myth","Video"],
        0.27    =>    ["Capture","Channel","Content","Dvr","Frontend","Guide","Myth","Video"],
        0.28    =>    ["Capture","Channel","Content","Dvr","Frontend","Guide","Myth","Video","Image","Rtti"],
        0.29    =>    ["Capture","Channel","Content","Dvr","Frontend","Guide","Myth","Video","Image","Rtti"],
        # Added current version and removed frontend service for backend-only system
        29.1    =>    ["Capture","Channel","Content","Dvr","Guide","Myth","Video","Image","Rtti"],
    );   
   
    my $self   = {
        '_server'            =>    undef,
        '_backendport'    =>    6544,
        '_frontendport'    =>    6547,
        'MythVersions'    => {},
        'Services'        => {}
    };   

    #Add suported myth versions to the visible class variables.
    $self->{'MythVersions'} = \%mythversion;
   
    if (@_)    {
        foreach my $key (keys %options)    {
            if ( $key eq 'server'){
                $self->{_server}= $options{$key};
            }
            elsif ( $key eq 'backendport'){
                $self->{_backendport}= $options{$key};
            }
            elsif ( $key eq 'frontendport') {
                $self->{_frontendport} = $options{$key};
            }           
        }
        if ( !defined $self->{_server}) {
            die("must at least specify a server to connect to.");
        }
    } else {
        die("must specify a server to connect to.");
    }
   
    bless($self, $class);
    $self->_initAPI();
   
    return $self;
}

sub _run {
    my($self,$method, %args) = @_;
    my $mythService;
   
    FINDMETHOD: foreach my $service ( sort(keys %{$self->{Services}}) ) {
        foreach my $serviceMethod ( @{$self->{Services}->{$service}} ) {
            if ( lc $method eq lc $serviceMethod) {
                $mythService=$service;
                $method=$serviceMethod;
                last FINDMETHOD
            }
        }
    }   
   
    my $soapcall = $self->_buildSOAPConnection ($mythService);
    #SOAP returns results in Perl data structures.
    return $soapcall->$method(%args);
}

sub _buildSOAPConnection {
    my $self = shift;
    my ($mythService) = @_;
    my $URI;
   
    if ( lc $mythService eq lc "frontend" ) {
            $URI = "http://". $self->{_server}.":".$self->{_frontendport}."/".$mythService."/wsdl";
    } else    {
            $URI = "http://". $self->{_server}.":".$self->{_backendport}."/".$mythService."/wsdl";
    }
   
    return SOAP::Lite->service($URI);
}

sub _initAPI{
    my $self = shift;
    my $methodList;
    my @key;
    my $URI;
   
    #Use the one supported service and method on all Myth Versions since 0.25 to determin
    #which mythtv version we are accessing.
    my $useAPI = $self->_matchAPI($self->_getMajorMinorVersion());

    #Build a list of services and methods based on MythTV Version;   
    foreach my $service (@{$self->{'MythVersions'}{$useAPI}}) {
        if ($service eq "Frontend") {
            $URI = "http://". $self->{_server}.":".$self->{_frontendport}."/".$service."/wsdl";
        } else    {
            $URI = "http://". $self->{_server}.":".$self->{_backendport}."/".$service."/wsdl";
        }
   
        my $serviceMethods = SOAP::Schema->new( schema_url => $URI);
        $serviceMethods->parse();
        $methodList = $serviceMethods->services();
        @key = keys %{$methodList};
       
        my @tmp = sort(keys(%{$methodList->{$key[0]}}));
        $self->{Services}->{$service}= [@tmp];
    }
}

# This call should return the same version as passed in to the call.
# If the MythTV system is a higher version we return the closest matching version
sub _matchAPI {
    my $self = shift;
    my ($ver) = @_;
    my @versions = sort (keys (%{$self->{'MythVersions'}}));
    my $index=0;
    my $temp;

    do{
        if ( $ver == $versions[$index]){
            return $ver;
        } else {
            $index++;
            #If ver is larger than higest version we know about make sure we pass
            #back to calling routine the highest version we support.
            if ( $ver > $versions[$index]) {
                $temp = $versions[$index];
            }
        }
       
    }while ($index <= @versions);
    #we did not match any known mythtv versions
    return $temp;
}

#Get the current mythtv version.
sub _getMajorMinorVersion {
    my $self = shift;
   
    my $temp = $self->_buildSOAPConnection("Myth");
    my $data = $temp->GetConnectionInfo();
    my $ret = $data->{Version}->{Version};
   
    #Get only Major and Minor version from returned string.
    $ret = substr($ret, 1,4);
    return $ret;    #Example return 0.27 instead of v0.27.6
}

#Use AUTOLOAD to simulate Service API function calls as part of this object.
#Process method call and access apropriate API call.
sub AUTOLOAD{
    my($self,%args) = @_;
    our $AUTOLOAD;

    #seperate AUTOLOAD into class and method
    my ($class,$method) = $AUTOLOAD =~ m/^(.+)::(.+)$/;
    $self->_run($method,%args);
}

sub DESTROY{
    my($self) = @_;
    $self = undef;
}

1;


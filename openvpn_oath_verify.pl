#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use JSON; # use your favorit storage or API

use Authen::OATH;
use Convert::Base32 qw(decode_base32);

use constant {
    USERS_FILE => '/etc/openvpn.users.pass'
    # file format
    # {
    #     "user": {
    #         "password": "mypassword",
    #         "secret":   "mysecret"
    #     },
    #     ...
    # }
};



# get username and password from openvpn
if (!defined($ARGV[0])) {
    print "No username/password file specified on command line\n";
    exit(1);
}

my $fh;
if (!open($fh, '<', $ARGV[0])) {
    print "Could not open username/password file: ".$ARGV[0]."\n";
    exit(1);
}

my $username = <$fh>;
my $password = <$fh>;

if (!defined($username) || !defined($password) || 0 == length($username)) {
    print "Username/password not found in file: ".$ARGV[0]."\n";
    exit(1);
}

chomp($username, $password);


if ($password !~ /^(.*)(\d{6})$/) {
    print "Incorrect password mask\n";
    exit(1);
}

$password       = $1;
my $secret_code = $2;


# use your favorit storage or API
if (!open($fh, '<', USERS_FILE)) {
    print "Could not open username/password file: ".USERS_FILE."\n";
    exit(1);
}

my $users_json;
eval {
     local $/; # slurp mode
     $users_json = decode_json(<$fh>);
};
if ($@) {
    print "Could not parse username/password file (Wrong format): ".USERS_FILE." $@\n";
    exit(1);
}

if (!exists( $users_json->{$username} )) {
    print "Could not find user: ".$username."\n";
    exit(1);
}

if (!defined( $users_json->{$username}{password} ) || !defined( $users_json->{$username}{secret} )) {
    print "Could not find password or secret for user ".$users_json->{$username}." (Wrong format) in file: ".USERS_FILE."\n";
    exit(1);
}


# check data
my $oath = Authen::OATH->new();
my $otp = $oath->totp(decode_base32( $users_json->{$username}{secret} ));

# $ENV{'common_name'} also available here
if ($users_json->{$username}{password} eq $password && $otp eq $secret_code) {
    exit(0); # Success
}

exit(1);
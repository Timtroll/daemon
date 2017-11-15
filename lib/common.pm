package common;

use utf8;
use warnings;
use strict;

use Mojo::Home;
use Digest::MD5 qw/md5_hex/;
use Time::localtime;
use JSON::XS;


use Data::Dumper;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $config $dots $error_mess $clear );

use Data::Dumper;

my $config = {};
my $dots = {};
my $error_mess = [];

my $cllear = {};

BEGIN {
	# set not verify ssl connection
	IO::Socket::SSL::set_ctx_defaults(
		'SSL_verify_mode' => 0 #'SSL_VERIFY_NONE'
	);
	$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = '0';
};

@ISA = qw( Exporter );
@EXPORT = qw( &rel_file &error $config $dots $error_mess $clear );

# Find and manage the project root directory
my $home = Mojo::Home->new;
$home->detect;

sub rel_file { $home->rel_file(shift); }

sub error {
	my $self = shift;

	$self->res->code(301);
	$self->redirect_to('/fail');
	return;
}

1;

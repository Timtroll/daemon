package Geo::Helpers::Validate;

use utf8;
use strict;
use warnings;

use open ':encoding(UTF-8)';	# Default encoding of file handles.
use Encode qw(decode encode);
use Time::Local;

use base 'Mojolicious::Plugin';

use Data::Dumper;

use common;
# use lmt_dbm;

BEGIN {
	binmode STDIN;						# Usually does nothing on non-Windows.
	binmode STDOUT, ":encoding(UTF-8)";	# Usually does nothing on non-Windows.
	binmode STDERR, ":encoding(UTF-8)";	# For text sent to the log file.
}

sub register {
	my ($self, $app) = @_;

	# check exists item in DB
	$app->helper('existsitem'		=> \&existsitem);

	# prepare validate functions
	$app->helper('prepare_validate'	=> \&prepare_validate);

	# validate group fields
	$app->helper('validate_group'	=> \&validate_group);

	# validate one field
	$app->helper('validate'			=> \&validate);

	# convet dd-mm-yyy to seconds
	$app->helper('date2sec'			=> \&date2sec);

	# convet seconds to dd-mm-yyy
	$app->helper('sec2date'			=> \&sec2date);

	# convet seconds to dd-mm-yyy
	$app->helper('sec2time'			=> \&sec2time);

}

# set falidate functions
sub prepare_validate {
	map {
		my $key = $_;
		$$clear{$key} = sub {
			my ($name, $data, $error);

			unless ($_[1]) { return 0; }
			unless ($_[0]) { $_[0] = time(); }

			my $reg = $$config{'validate'}{$key};

			if ($key =~ m/(string|symbchars|chars)/) {
				if ($_[1] =~ m/$reg/) {
					$error = `date`." : Incorrect '$key' field '$_[0]' input data='$_[1]'; ";
					$error =~ s/(\n|\r)//g;
					# $$error_input{$_[0]} = $error;
					push @{$error_mess}, $error;
				}

				$_[1] =~ s/$reg//g;
			}
			else {
				unless ($_[1] =~ m/$reg/) {
					$error = `date`." : Incorrect '$key' field '$_[0]' input data='$_[1]'; ";
					$error =~ s/(\n|\r)//g;
					# $$error_input{$_[0]} = $error;
					push @{$error_mess}, $error;

					return;
				}
			}

			return $_[1];
		}
	} (keys %{$$config{'validate'}});
}

# validate group of fields
sub validate_group {
	my ($self, $input, $exclude, $type, $tmp, %out);
	$self = shift;
	$input = shift;
	$exclude = shift;

	%out = ();
	unless ($exclude) { $exclude = {}; }
	map {
		my $field = $_;
		if ($field) {
			# validate field
			unless (exists $$exclude{$field}) {
				unless ($field =~ /^status/) {
					# $out{$field} = $self->param($field);
					$out{$field} = $self->req->json->{$field};
					if ($type = $$input{$field}) {
						unless (exists $$config{'validate'}{$type}) {
							# $$error_input{$field} = "Field '$field' - unknown validate type: $type";
							push @{$error_mess}, "Field '$field' - unknown validate type: $type";
							$out{$field} = '';
						}
						else {
							$tmp = '';
							# if ($tmp = $self->param($field)) {
							if ($tmp = $self->req->json->{$field}) {
								unless ($out{$field} = $$clear{$type}($field, $tmp)) {
									$out{$field} = '';
								}
							}
						}
					}
				}
				else {
					$out{$field} = 0;
					# if ($self->param($field)) {
					if ($self->req->json->{$field}) {
						$out{$field} = 1;
					}
				}
			}
			# skip validate field
			else {
				# $out{$field} = $self->param($field);
				$out{$field} = $self->req->json->{$field};
			}
		}
	} (keys %{$input});

	return \%out;
}

# validate one field
sub validate {
	my ($self, $type, $field) = @_;

	unless ($field =~ /^status/) {
		unless (exists $$config{'validate'}{$type}) {
			# $$error_input{$field} = 'Unknown validate type';
			push @{$error_mess}, "Unknown validate type";
			return 0;
		}

		if ($self->req->json->{$field}) {
		# if ($self->param($field)) {
			# return $$clear{$type}($field, $self->param($field));
			return $$clear{$type}($field, $self->req->json->{$field});
		}
	}
	else {
		my $out = 0;
		# if ($self->param($field)) {
		if ($self->req->json->{$field}) {
			$out = 1;
		}
		return $out;
	}

	return 0;
}

sub date2sec {
	my ($self, $date, @tmp);
	$self = shift;
	$date = shift;

	@tmp = split('-', $date);
	$tmp[0] = int($tmp[0]);
	$tmp[1] = int($tmp[1]) - 1;
	$tmp[2] = int($tmp[2]);
	if (($tmp[0] < 0)||($tmp[0] > 59)) {
		if ($$config{'debug'}) { push @{$error_mess}, "Wrong input day"; }
		$tmp[0] = 0;
	}
	elsif (($tmp[1] < 1)||($tmp[1] > 60)) {
		if ($$config{'debug'}) { push @{$error_mess}, "Wrong input month"; }
		$tmp[1] = 0;
	}
	elsif (($tmp[2] < 1000)||($tmp[2] > 9999)) {
		if ($$config{'debug'}) { push @{$error_mess}, "Wrong input year"; }
		$tmp[2] = 1900;
	}
	return timelocal(0, 0, 0, @tmp);
}

sub sec2date {
	my ($self, $sec);
	$self = shift;
	$sec = shift;

	unless ($sec) { $sec = time(); }

	return sprintf('%02d',(localtime($sec))[3]).'.'.sprintf('%02d',(localtime($sec))[4] + 1).'.'.((localtime($sec))[5] + 1900).' '.sprintf('%02d',(localtime($sec))[2]).':'.sprintf('%02d',(localtime($sec))[1]).':'.sprintf('%02d',(localtime($sec))[0]);
}

sub sec2time {
	my ($self, $sec, $showsec);
	$self = shift;
	$sec = shift;
	$showsec = shift;

	unless ($sec) { $sec = time(); }

	if ($showsec) {
		return sprintf('%02d',(localtime($sec))[2]).':'.sprintf('%02d',(localtime($sec))[1]).':'.sprintf('%02d',(localtime($sec))[0]);
	}
	else {
		return sprintf('%02d',(localtime($sec))[2]).':'.sprintf('%02d',(localtime($sec))[1]);
	}
}

1;
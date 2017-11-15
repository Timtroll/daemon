package Geo::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';

use Time::localtime;
use common;

use Data::Dumper;

sub index {
	my ($self, $res);
	$self = shift;

	$self->render(json => {'status' => 'ok'} );
}

sub del {
	my ($self, $in, $out);
	$self = shift;

	$in = $self->validate_group($$config{'fields'});

	$out = {'status' => 'fail', 'message' => "Check id"};
	if ($$in{'id'}) {
		if (exists $$dots{$$in{'id'}}) {
			delete $$dots{$$in{'id'}};
			$out = {'status' => 'ok', 'message' => "deleted"};
		}
	}

	$self->render(json => $out );
}

sub get {
	my ($self, $in, $out);
	$self = shift;

	$in = $self->validate_group($$config{'fields'});

	$out = {'status' => 'fail', 'message' => "Check id"};
	if ($$in{'id'}) {
		if (exists $$dots{$$in{'id'}}) {
			$out = $$dots{$$in{'id'}};
		}
	}

	$self->render(json => $out );
}

sub getall {
	my ($self, $in);
	$self = shift;

	$in = $self->validate_group($$config{'fields'});
	unless (keys %{$dots}) {
		$dots = {};
	}

	$self->render(json => $dots );
}


sub add {
	my ($self, $status, $in, $out);
	$self = shift;

	$in = $self->validate_group($$config{'fields'});

	unless ($$in{'id'})			{ push @{$error_mess}, "Check id"; }
	unless ($$in{'latitude'})	{ push @{$error_mess}, "Check latitude"; }
	unless ($$in{'longitude'})	{ push @{$error_mess}, "Check longitude"; }
	# unless ($$in{'altitude'})	{ push @{$error_mess}, "Check altitude"; }
	unless ($$in{'name'})		{ push @{$error_mess}, "Check name"; }

	$out = {'status' => 'ok'};
	unless (scalar(@{$error_mess})) {
		$$dots{$$in{'id'}} = {
			'expired'	=> (time() + $$config{'expired'}),
			'date'		=> $self->sec2date(),
			'id'		=> $$in{'id'},
			'latitude'	=> $$in{'latitude'},
			'longitude'	=> $$in{'longitude'},
			'altitude'	=> $$in{'altitude'},
			'status'	=> $$in{'status'},
			'name'		=> $$in{'name'}
		};
	}
	else {
		$out = {'status' => 'fail', 'message' => $error_mess};
	}

	$self->render(json => $out);
}

sub fail {
	my ($self, $res);
	$self = shift;

	$self->render(json => {'status' => 'fail', 'message' => $error_mess} );
}

sub check {
	my ($self, $res);
	$self = shift;

	$error_mess = [];

	unless ($self->req->json) { push @{$error_mess}, "Fail"; }
	else {
		unless (exists $self->req->json->{'token'}) { push @{$error_mess}, "Fail token"; }
	}

	unless (scalar(@{$error_mess})) {
		# проверяем хард токен
		if ($self->req->json->{'token'} eq $$config{'token'}) {
			if ($self->req->json->{'token'} eq $$config{'token'}) {
				# delete exiped items
				map {
					if (exists $$dots{$_}{'expired'}) {
						if ($$dots{$_}{'expired'} < time()) {
							delete $$dots{$_};
						}
					}
				} (keys %{$dots});

				return 1;
			}
			else {
				push @{$error_mess}, "Wrong token";
			}
		}
		else {
			push @{$error_mess}, "Empty token";
		}
	}

	$self->res->code(301);
	$self->redirect_to('/fail');
	return;
}

1;

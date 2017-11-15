package Geo;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;

$| = 1;

use common;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Load configuration from hash returned by "my_app.conf"
	$config = $self->plugin('Config');

	# set life-time fo session (second)
	$self->sessions->default_expiration($config->{'expires'});

	$self->plugin('Geo::Helpers::Validate');

	# prepare validate functions
	$self->prepare_validate();

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->any('/')			->to('index#index')			->name('Главная');
	$r->any('/fail')		->to('index#fail')			->name('Ошибочка');

	my $auth = $r->under()	->to('index#check');

	$auth->any('/add')		->to('index#add')			->name('Добавить точку');
	$auth->any('/get')		->to('index#get')			->name('Получить точку');
	$auth->any('/getall')	->to('index#getall')		->name('Получить все точки');
	$auth->any('/del')		->to('index#del')			->name('Удалить точку');

	$r->any('/*')			->to('index#fail')			->name('Ошибочка');

# /add
# JSON:
# {
# 	"token":	"6zeddjxuix694zod7yo49k3snzmjbk98hu1exk6e",
# 	"id":		"12425325",
# 	"latitude":	"59.949159",
# 	"longitude":"30.230726",
# 	"name":		"Квадро 3",
# 	"status":	1
# }

# /get
# JSON:
# {
# 	"token": "6zeddjxuix694zod7yo49k3snzmjbk98hu1exk6e",
# 	"id": "12425325"
# }

# /getall
# JSON:
# {
# 	"token": "6zeddjxuix694zod7yo49k3snzmjbk98hu1exk6e"
# }

# /del
# JSON:
# {
# 	"token": "6zeddjxuix694zod7yo49k3snzmjbk98hu1exk6e",
# 	"id": "12425325"
# }

}

1;

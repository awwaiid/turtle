#!/usr/bin/perl

use strict;
use lib 'lib';

use SDLx::Coro::REPL;
use SDLx::Controller::Coro;

use Coro;
use Coro::EV;
use AnyEvent;

use SDL;
use SDLx::App;
use SDLx::Rect;
use SDL::Event;
use SDL::Video;


use MooseX::Declare;
class Turtle {
  has app => (is => 'rw');
  has x => (is => 'rw');
  has y => (is => 'rw');
  has angle => (is => 'rw');
  has pen_down => (is => 'rw', default => sub { 1 });
  has color => (is => 'rw', default => sub { [255, 255, 255, 255] });

  use Math::Trig::Degree qw(dsin dcos);
  use AnyEvent;

  method forward($distance) {
    my $x_delta = $distance * dcos($self->angle);
    my $y_delta = $distance * dsin($self->angle);
    my $new_x = $self->x + $x_delta;
    my $new_y = $self->y + $y_delta;
    $self->jumpto( $new_x, $new_y );
  }

  method left( $angle ) {
    $self->angle( ($self->angle() - $angle) % 360 );
  }
  
  method right( $angle ) {
    $self->angle( ($self->angle() + $angle) % 360 );
  }

  method jumpto( $new_x, $new_y ) {
    if($self->pen_down) {
      $self->app->draw_line(
        [$self->x, $self->y] => [$new_x, $new_y],
        $self->color,
        1 # antialias
      );
    }
    $self->x($new_x);
    $self->y($new_y);
    my $done = AnyEvent->condvar;
    my $delay = AnyEvent->timer( after => 0.01, cb => sub { $done->send;  } );
  }

  method penup {
    $self->pen_down(0);
  }

  method pendown {
    $self->pen_down(1);
  }

}

our $app;
our $pixel_format;
our $t;

sub init_video {

  SDL::Video::wm_grab_input( SDL_GRAB_ON );
  SDL::init( SDL_INIT_VIDEO );

  $app = SDLx::App->new(
    -title => 'rectangle',
    -width => 640,
    -height => 480,
  );
  
  clear();

}

sub clear {
  # Initial background
  $pixel_format = $app->format;
  my $black_pixel = SDL::Video::map_RGB( $pixel_format, 0x00, 0x00, 0x00 );
  my $rect = SDL::Rect->new( 0,0, $app->w, $app->h);
  SDL::Video::fill_rect( $app, $rect, $black_pixel );
}


sub main {
  init_video();

  my $game = SDLx::Controller::Coro->new;

  $game->add_event_handler( sub {
    my $event = shift;
    # print STDERR "In event handler\n";
    if($event->type == SDL_QUIT) {
      print "All done!\n";
      exit;
    }
    return 1;
  });

  $game->add_show_handler( sub {
    SDL::Video::update_rect($app, 0, 0, 640, 480);
  });
  
  # Make me a TURTLE
  $t = Turtle->new(app => $app, x => 300, y => 300, angle => 0);

  if($ARGV[0]) {
    print "Loading $ARGV[0]\n";
    do $ARGV[0];
  }

  start_repl($game);

}

sub start_repl {
  my $game = shift;
  print q{

Welcome to the TURTLE REPL!

};

  my $repl = SDLx::Coro::REPL::start();

  $repl->eval('my $t = $::t');

  # Give the REPL access to the $app
  $repl->eval('my $app = $::app');

  $game->run;
}

# Export some turtle work int the main namespace for convenience
sub forward { $t->forward(@_) }
sub left { $t->left(@_) }
sub right { $t->right(@_) }
sub pendown { $t->pendown(@_) }
sub penup { $t->penup(@_) }
sub jumpto { $t->jumpto(@_) }

main();


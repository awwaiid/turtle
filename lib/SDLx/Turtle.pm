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
    $new_x = $new_x % 640;
    $new_y = $new_y % 480;
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


package Device::WebIO::Firmata;

# ABSTRACT: Interface between Device::WebIO and Device::Firmata (Arduino)
use v5.12;
use Moo;
use namespace::clean;
use Device::Firmata ();
use Device::Firmata::Constants qw{ :all };

has '_firmata' => (
    is  => 'ro',
);
has 'input_pin_count' => (
    is  => 'ro',
    # Max GPIO pins Firmata supports.  Would be nice if it had a way to 
    # detect how many pins are actually on the device.
    default => sub { 128 },
);
has 'output_pin_count' => (
    is      => 'ro',
    default => sub { 128 },
);

with 'Device::WebIO::Device::DigitalOutput';
with 'Device::WebIO::Device::DigitalInput';
# TODO
#with 'Device::WebIO::Device::PWM';
#with 'Device::WebIO::Device::ADC';


sub BUILDARGS
{
    my ($class, $args) = @_;
    my $port = delete $args->{port};

    my $dev = Device::Firmata->open( $port )
        or die "Could not connect to Firmata Server on '$port'\n";
    $args->{'_firmata'} = $dev;

    return $args;
}

sub output_pin
{
    my ($self, $pin, $set) = @_;
    $self->_firmata->digital_write( $pin, $set );
    return 1;
}

sub input_pin
{
    my ($self, $pin) = @_;
    my $value = $self->_firmata->digital_read( $pin );
    return $value;
}

sub set_as_output
{
    my ($self, $pin) = @_;
    $self->_firmata->pin_mode( $pin, PIN_OUTPUT );
    return 1;
}

sub set_as_input
{
    my ($self, $pin) = @_;
    $self->_firmata->pin_mode( $pin, PIN_INPUT );
    return 1;
}


1;

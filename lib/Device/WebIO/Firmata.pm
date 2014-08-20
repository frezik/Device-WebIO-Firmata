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
has 'pwm_pin_count' => (
    is      => 'ro',
    default => sub { 128 },
);

with 'Device::WebIO::Device::DigitalOutput';
with 'Device::WebIO::Device::DigitalInput';
with 'Device::WebIO::Device::PWM';
with 'Device::WebIO::Device::ADC';


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


sub pwm_bit_resolution
{
    my ($self, $pin) = @_;
    # Arduino Uno bit resolution
    return 8;
}

{
    my %did_set_pwm;
    sub pwm_output_int
    {
        my ($self, $pin, $value) = @_;
        my $firmata = $self->_firmata;

        $firmata->pin_mode( $pin, PIN_PWM )
            if ! exists $did_set_pwm{$pin};
        $did_set_pwm{$pin} = 1;

        $firmata->analog_write( $pin, $value );
        return 1;
    }
}

sub adc_bit_resolution
{
    my ($self, $pin) = @_;
    # Arduino Uno bit resolution
    return 10;
}

sub adc_volt_ref
{
    my ($self, $pin) = @_;
    # Arduino Uno, except when it's 3.3V.  This is a rather large assumption. 
    # TODO fix this
    return 5.0;
}

sub adc_pin_count
{
    my ($self, $pin) = @_;
    return 128;
}

{
    my %did_set_adc;
    sub adc_input_int
    {
        my ($self, $pin) = @_;
        my $firmata = $self->_firmata;

        $firmata->pin_mode( $pin, PIN_ANALOG )
            if ! exists $did_set_adc{$pin};
        $did_set_adc{$pin} = 1;

        my $value = $firmata->analog_write( $pin );
        return $value;
    }
}


1;

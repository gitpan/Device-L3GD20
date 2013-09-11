package Device::L3GD20::Gyroscope;

# PODNAME: Device::L3GD20::Gyroscope
# ABSTRACT: I2C interface to Gyroscope on the L3GD20 using Device::SMBus
#
# This file is part of Device-L3GD20
#
# This software is copyright (c) 2013 by Shantanu Bhadoria.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
our $VERSION = '0.001'; # VERSION

use 5.010;
use Moose;
use POSIX;

extends 'Device::SMBus';

has '+I2CDeviceAddress' => (
    is      => 'ro',
    default => 0x6b,
);

# Registers for the Gyroscope
use constant {
    CTRL_REG1 => 0x20,
    CTRL_REG4 => 0x23,
};

# X, Y and Z Axis Gyroscope Data value in 2's complement
use constant {
    OUT_X_H => 0x29,
    OUT_X_L => 0x28,

    OUT_Y_H => 0x2b,
    OUT_Y_L => 0x2a,

    OUT_Z_H => 0x2d,
    OUT_Z_L => 0x2c,
};

use integer
  ; # Use arithmetic right shift instead of unsigned binary right shift with >> 4


sub enable {
    my ($self) = @_;
    $self->writeByteData( CTRL_REG1, 0b00001111 );
    $self->writeByteData( CTRL_REG4, 0b00110000 );
}


sub getRawReading {
    my ($self) = @_;

    return (
        x => (
            $self->_typecast_int_to_int16(
                ( $self->readByteData(OUT_X_H) << 8 ) |
                  $self->readByteData(OUT_X_L)
            )
        ),
        y => (
            $self->_typecast_int_to_int16(
                ( $self->readByteData(OUT_Y_H) << 8 ) |
                  $self->readByteData(OUT_Y_L)
            )
        ),
        z => (
            $self->_typecast_int_to_int16(
                ( $self->readByteData(OUT_Z_H) << 8 ) |
                  $self->readByteData(OUT_Z_L)
            )
        ),
    );
}

sub _typecast_int_to_int16 {
    return unpack 's' => pack 'S' => $_[1];
}

sub calibrate {
    my ($self) = @_;

}

1;

__END__

=pod

=head1 NAME

Device::L3GD20::Gyroscope - I2C interface to Gyroscope on the L3GD20 using Device::SMBus

=head1 VERSION

version 0.001

=head1 METHODS

=head2 enable 

    $self->enable()

Initializes the device, Call this before you start using the device. This function sets up the appropriate default registers.
The Device will not work properly unless you call this function

=head2 getRawReading

    $self->getRawReading()

Return raw readings from accelerometer registers

=head1 AUTHOR

Shantanu Bhadoria <shantanu at cpan dott org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

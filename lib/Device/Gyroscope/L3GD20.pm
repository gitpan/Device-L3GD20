use strict;
use warnings;

package Device::Gyroscope::L3GD20;

# PODNAME: Device::Gyroscope::L3GD20
# ABSTRACT: I2C interface to Gyroscope on the L3GD20 using Device::SMBus
#
# This file is part of Device-L3GD20
#
# This software is copyright (c) 2013 by Shantanu Bhadoria.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
our $VERSION = '0.005'; # VERSION

# Dependencies
use 5.010;
use Moose;
use POSIX;

use Time::HiRes qw(time);

extends 'Device::SMBus';


has '+I2CDeviceAddress' => (
    is      => 'ro',
    default => 0x6b,
);


has gyroscopeGain => (
    is      => 'rw',
    default => 0.07,
);


has XZero => (
    is      => 'rw',
    default => 0,
);


has YZero => (
    is      => 'rw',
    default => 0,
);


has ZZero => (
    is      => 'rw',
    default => 0,
);


has lastReadingTime => (
    is      => 'rw',
    default => 0,
);


has timeDrift => (
    is      => 'rw',
    default => 0,
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

#use integer; # Use arithmetic right shift instead of unsigned binary right shift with >> 4


sub enable {
    my ($self) = @_;
    $self->writeByteData( CTRL_REG1, 0b00001111 );
    $self->writeByteData( CTRL_REG4, 0b00110000 );
}


sub getRawReading {
    my ($self) = @_;

    my $currentTime = time;
    $self->timeDrift( $currentTime - $self->lastReadingTime )
      if $self->lastReadingTime;
    $self->lastReadingTime($currentTime);

    return {
        x =>
          ( $self->_typecast_int_to_int16( $self->readNBytes( OUT_X_L, 2 ) ) )
          - $self->XZero,
        y =>
          ( $self->_typecast_int_to_int16( $self->readNBytes( OUT_Y_L, 2 ) ) )
          - $self->YZero,
        z =>
          ( $self->_typecast_int_to_int16( $self->readNBytes( OUT_Z_L, 2 ) ) )
          - $self->ZZero,
    };
}


sub getReading {
    my ($self) = @_;

    my $gain = $self->gyroscopeGain;
    my $gyro = $self->getRawReading;
    return {
        x => ( $gyro->{x} * $gain ),
        y => ( $gyro->{y} * $gain ),
        z => ( $gyro->{z} * $gain ),
    };
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

Device::Gyroscope::L3GD20 - I2C interface to Gyroscope on the L3GD20 using Device::SMBus

=head1 VERSION

version 0.005

=head1 ATTRIBUTES

=head2 I2CDeviceAddress

Contains the I2CDevice Address for the bus on which your gyroscope is connected. It would look like 0x6b. Default is 0x6b.

=head2 gyroscopeGain

Unless you are modifying gyroscope setup you must not change this. This contains the Gyroscope gain value which helps in converting the raw measurements from gyroscope register in to degrees per second.

=head2 XZero

This is the raw value for the X axis when the gyro is stationary. This is a part of gyro calibration to get more accurate values for rotation.

=head2 YZero

This is the raw value for the Y axis when the gyro is stationary. This is a part of gyro calibration to get more accurate values for rotation.

=head2 ZZero

This is the raw value for the Z axis when the gyro is stationary. This is a part of gyro calibration to get more accurate values for rotation.

=head2 lastReadingTime

Time when the last reading was taken

=head2 timeDrift

time taken between last reading and current reading. 
Make sure to take atleast two readings before you use this value for any calculations in your program otherwise you will get a bad value in this the first time you read the gyroscope.

=head1 METHODS

=head2 enable 

    $self->enable()

Initializes the device, Call this before you start using the device. This function sets up the appropriate default registers.
The Device will not work properly unless you call this function

=head2 getRawReading

    $self->getRawReading()

Return raw readings from accelerometer registers. Note that if XZero,YZero or ZZero are set, this function returns the values adjusted from the values at default non rotating state of the gyroscope. Its recommended that you set these values to achieve accurate results from the gyroscope.

=head2 getReading

Return gyroscope readings in degrees per second

=head2 calibrate

Placeholder for documentation on calibration

=head1 REGISTERS

=head2 CTRL_REG1

=head2 CTRL_REG4

=head2 OUT_X_H

=head2 OUT_X_L

=head2 OUT_Y_H

=head2 OUT_Y_L

=head2 OUT_Z_H

=head2 OUT_Z_L

=head1 AUTHOR

Shantanu Bhadoria <shantanu at cpan dott org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

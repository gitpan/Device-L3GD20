use FindBin qw($Bin);
use lib "$Bin/../lib";

use Device::L3GD20::Gyroscope;

my $g = Device::L3GD20::Gyroscope->new( I2CBusDevicePath => '/dev/i2c-1' );
$g->enable();
use Data::Dumper;
while () {
    print 'Gyroscope: ' . Dumper { $g->getRawReading() };
}

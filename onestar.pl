use strict;
use warnings;
no warnings 'uninitialized';

use ProceeduralUniverse::Space;
use Math::BigInt;
use Storable qw(store retrieve freeze thaw dclone);
use Data::Dumper;

my $system = ProceeduralUniverse::Space::GenerateNewStarSystem({
	IGNOREBLANK => 1,
});
#print Dumper($system);

print ProceeduralUniverse::Space::PrettyPrintString({SYSTEM => $system});

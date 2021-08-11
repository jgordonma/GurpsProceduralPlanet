use strict;
use warnings;
no warnings 'uninitialized';

use ProceeduralUniverse::Space;
use Math::BigInt;
use Storable qw(store retrieve freeze thaw dclone);
use Data::Dumper;
use Memory::Usage;
use Term::Screen::Uni;
use AthenaUtils;
my $mu = Memory::Usage->new();

my $keymap => {
	Q => 'QUIT',
	W => 'NORTH',
	A => 'WEST',
	S => 'SOUTH',
	D => 'EAST',
	Z => 'UP',
	X => 'DOWN',
}

my @directions = qw( EAST WEST NORTH SOUTH UP DOWN );

my @space;

my ($size) = @ARGV;

$size ||= 100;

for my $x (0..$size){
	# Record amount of memory used by current process
	#$mu->record("New X = $x");
	for my $y (0..$size){
		for my $z (0..$size){
			$space[$z][$y][$x] = ProceeduralUniverse::Space::GenerateNewStarSystem();
		}
	}
	# Record amount in use afterwards
	#$mu->record("After X = $x");
	# Spit out a report
	#$mu->dump();
}
#print Dumper(\@space);
my $coords = {
	X => int($size / 2),
	Y => int($size / 2),
	Z => int($size / 2),
};
ProceeduralUniverse::Space::PrintSpace({ MAP => \@space, COORDS => $coords, SIGHTRANGE => 2});
print "> ";
while(){
    my $key;
    open(TTY, "+</dev/tty") or die "no tty: $!";
    system "stty  cbreak </dev/tty >/dev/tty 2>&1";
    sysread(TTY, $key, 1);  # probably this does
    system "stty -cbreak </dev/tty >/dev/tty 2>&1";
    my $action = $keymap{uc($key)};
    last if $action eq 'QUIT';
    if (InList($action, @directions)){
    	ProceeduralUniverse::Space::Move({ MAP => \@space, COORDS => $coords, DIRECTION => $action});
    }
    ProceeduralUniverse::Space::PrintSpace({ MAP => \@space, COORDS => $coords, SIGHTRANGE => 2});
    print "> ";
}
#store \@space, 'space.out';

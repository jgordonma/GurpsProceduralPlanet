package ProceeduralUniverse::Space;

use strict;
use warnings;
no warnings 'uninitialized';

use Math::BigInt;
use Games::Dice 'roll';
use Data::Dumper;
use List::Util qw(first);

our @SIZE_LIST = qw(TINY SMALL STANDARD LARGE);

our %LUMINOSITYCHART = (
	#Mass Type Temp L-Min L-Max M-Span S-Span G-Span
	0.10 => [qw(M7 3100 0.0012 - - - -)],
	0.15 => [qw(M6 3200 0.0036 - - - -)],
	0.20 => [qw(M5 3200 0.0079 - - - -)],
	0.25 => [qw(M4 3300 0.015 - - - -)],
	0.30 => [qw(M4 3300 0.024 - - - -)],
	0.35 => [qw(M3 3400 0.037 - - - -)],
	0.40 => [qw(M2 3500 0.054 - - - -)],
	0.45 => [qw(M1 3600 0.07 0.08 70 - -)],
	0.50 => [qw(M0 3800 0.09 0.11 59 - -)],
	0.55 => [qw(K8 4000 0.11 0.15 50 - -)],
	0.60 => [qw(K6 4200 0.13 0.20 42 - -)],
	0.65 => [qw(K5 4400 0.15 0.25 37 - -)],
	0.70 => [qw(K4 4600 0.19 0.35 30 - -)],
	0.75 => [qw(K2 4900 0.23 0.48 24 - -)],
	0.77 => [qw(K1 5000 0.26 0.56 22 - -)],
	0.80 => [qw(K0 5200 0.28 0.65 20 - -)],
	0.85 => [qw(G8 5400 0.36 0.84 17 - -)],
	0.90 => [qw(G6 5500 0.45 1.0 14 - -)],
	0.95 => [qw(G4 5700 0.56 1.3 12 1.8 1.1)],
	1.00 => [qw(G2 5800 0.68 1.6 10 1.6 1.0)],
	1.05 => [qw(G1 5900 0.87 1.9 8.8 1.4 0.8)],
	1.10 => [qw(G0 6000 1.1 2.2 7.7 1.2 0.7)],
	1.15 => [qw(F9 6100 1.4 2.6 6.7 1.0 0.6)],
	1.20 => [qw(F8 6300 1.7 3.0 5.9 0.9 0.6)],
	1.25 => [qw(F7 6400 2.1 3.5 5.2 0.8 0.5)],
	1.30 => [qw(F6 6500 2.5 3.9 4.6 0.7 0.4)],
	1.35 => [qw(F5 6600 3.1 4.5 4.1 0.6 0.4)],
	1.40 => [qw(F4 6700 3.7 5.1 3.7 0.6 0.4)],
	1.45 => [qw(F3 6900 4.3 5.7 3.3 0.5 0.3)],
	1.50 => [qw(F2 7000 5.1 6.5 3.0 0.5 0.3)],
	1.55 => [qw(F2 7000 5.9 7.3 2.7 0.4 0.2)],
	1.60 => [qw(F0 7300 6.7 8.2 2.5 0.4 0.2)],
	1.65 => [qw(F0 7300 6.7 8.2 2.5 0.4 0.2)],
	1.70 => [qw(A9 7500 8.6 10 2.1 0.3 0.2)],
	1.75 => [qw(A9 7500 8.6 10 2.1 0.3 0.2)],
	1.80 => [qw(A7 7800 11 13 1.8 0.3 0.2)],
	1.85 => [qw(A7 7800 11 13 1.8 0.3 0.2)],
	1.90 => [qw(A6 8000 13 16 1.5 0.2 0.1)],
	1.95 => [qw(A6 8000 13 16 1.5 0.2 0.1)],
	2.00 => [qw(A5 8200 16 20 1.3 0.2 0.1)],
	2.10 => [qw(A5 9000 16 20 1.3 0.2 0.1)],
	2.30 => [qw(A5 9000 16 20 1.3 0.2 0.1)],
	2.40 => [qw(A5 9000 16 20 1.3 0.2 0.1)],
	3.0 => [qw(A4 9800 90 90 0 0 0.330)],
	5.0 => [qw(A3 14000 700 700 0 0 0.070)],
	7.5 => [qw(A2 18000 3600 3600 0 0 0.020)],
	10.0 => [qw(A1 20000 11000 11000 0 0 0.009)],
);

# RESULTMAP is a mapping of an arrayref of die roll results to the values that result
sub ConvertRollToOutput {
	my ($args) = @_;
	my $number_of_dice = $args->{NUMDICE};
	my $modifier = $args->{MODIFIER};
	my @results_array = @{$args->{RESULTARRAY}};
	my %array_to_result_map;
	foreach my $row (@results_array){
		my ($startvalue, $endvalue, $result) = @{$row};
		for(my $i=$startvalue; $i <= $endvalue; $i++){
			$array_to_result_map{$i} = $result;
		}
	}
	#print Dumper(\%array_to_result_map);
	my $dice_total = 0;
	for(my $i=0; $i < $number_of_dice; $i++ ){
		$dice_total += roll '1d6';
	}
	#print $dice_total;
	$dice_total += $modifier;
	return $array_to_result_map{$dice_total};
}

sub GenerateNewStarSystem {
	my ($args) = @_;

	my @stars;
	if (rand(1000) < 4 || $args->{IGNOREBLANK}){
		my $rand = roll '3d6';
		my $companionstars;

		if ($rand < 11){
			$companionstars = 0;
		}
		elsif ($rand < 16){
			$companionstars = 1;
		}
		else {
			$companionstars = 2;
		}
		my $primary = NewStar();
		if ($primary->{MASS} >= 3.0){
			print "Super Giant Created!\n";
		}
		push(@stars, $primary);
		for (my $i=0;$i < $companionstars; $i++){
			push(@stars, NewStar({
				COMPANIONTO => $primary,
				COMPANIONINDEX => $i,
			}));
		}
		return { 
			STARS => \@stars,
		};
	}
	else {
		return {};
	}
}

sub NewStar {
	my ($args) = @_;
	my $mass;
	my $age;
	my $star;
	# If we're generating a primary
	if(!$args->{COMPANIONTO}){
		$mass = NewPrimaryStellarMass();
		$age = StarSystemAge();
	}
	else{
		$mass = NewCompanionStellarMass({
			MAINSTARMASS => $args->{COMPANIONTO}->{MASS},
		});
		$age = $args->{COMPANIONTO}->{AGE};
		# Generate the orbit from the primary star.
		my $firstroll = roll '3d6';
		$firstroll += ($args->{COMPANIONINDEX} * 6);
		my $secondroll = roll '2d6';
		my $radiusmultiplier;
		if($firstroll <= 6){
			$radiusmultiplier = 0.05;
		}
		elsif($firstroll < 9 ){
			$radiusmultiplier = 0.5;
		}
		elsif($firstroll < 11 ){
			$radiusmultiplier = 2.0;
		}
		elsif($firstroll < 14 ){
			$radiusmultiplier = 10.0;
		}
		else {
			$radiusmultiplier = 50.0;
		}
		$star->{COMPANIONORBIT} = $secondroll * $radiusmultiplier;
		my $thirdroll = roll '3d6';
		if ($thirdroll <= 3){
			$star->{COMPANIONECCENTRICITY} = 0.0;
		}
		elsif ($thirdroll == 4){
			$star->{COMPANIONECCENTRICITY} = 0.1;
		}
		elsif ($thirdroll == 5){
			$star->{COMPANIONECCENTRICITY} = 0.2;
		}
		elsif ($thirdroll == 6){
			$star->{COMPANIONECCENTRICITY} = 0.3;
		}
		elsif ($thirdroll <= 8){
			$star->{COMPANIONECCENTRICITY} = 0.4;
		}
		elsif ($thirdroll <= 11){
			$star->{COMPANIONECCENTRICITY} = 0.5;
		}
		elsif ($thirdroll <= 13){
			$star->{COMPANIONECCENTRICITY} = 0.6;
		}
		elsif ($thirdroll <= 15){
			$star->{COMPANIONECCENTRICITY} = 0.7;
		}
		elsif ($thirdroll == 16){
			$star->{COMPANIONECCENTRICITY} = 0.8;
		}
		elsif ($thirdroll == 17){
			$star->{COMPANIONECCENTRICITY} = 0.9;
		}
		else {
			$star->{COMPANIONECCENTRICITY} = 0.95;
		}
		$star->{MINCOMPANIONORBIT} = (1 - $star->{COMPANIONECCENTRICITY}) * $star->{COMPANIONORBIT};
		$star->{MAXCONMANIONORBIT} = (1 + $star->{COMPANIONECCENTRICITY}) * $star->{COMPANIONORBIT};
		# Account for forbidden zones here...
		$star->{FORBIDDENZONEINSIDERADIUS} = (1/3) * $star->{MINCOMPANIONORBIT};
		$star->{FORBIDDENZONEOUTSIDERADIUS} = 3 * $star->{MAXCONMANIONORBIT};
	}
	$star->{AGE} = $age;
	$star->{MASS} = $mass;
	my $lum = StarLuminosity($star);
	$star->{INNERLIMIT} = 0.1 * $mass;
	if (0.01 * sqrt($lum->{LUMINOSITY}) > $star->{INNERLIMIT}){
		$star->{INNERLIMIT} = 0.01 * sqrt($lum->{LUMINOSITY});
	}
	$star->{OUTERLIMIT} = 40 * $mass;
	$star = {
		%$star,
		%$lum,
	};
	$star->{PLANETS} = GeneratePlanets({STAR => $star});
	return $star;
}

sub PrintSpace {
	my ($args) = @_;
	my $map = $args->{MAP};
	my $coords = $args->{COORDS};
	my $sightrange = $args->{SIGHTRANGE};
	$sightrange ||= 2;

	my $visible;
	if($coords){
		foreach my $axis ( 'X', 'Y', 'Z' ){
			my $currentpos = $coords->{$axis};
			my $maxaxis = @{$map} - 1;
			$visible->{$axis}->{MAX} = ($currentpos + $sightrange > $maxaxis ? $maxaxis : $currentpos + $sightrange);
			$visible->{$axis}->{MIN} = ($currentpos - $sightrange < 0 ? 0 : $currentpos - $sightrange);
		}
	}
	else {
		foreach my $axis ( 'X', 'Y', 'Z' ){
			$visible->{$axis}->{MAX} = @{$map} - 1;
			$visible->{$axis}->{MIN} = 0;
		}
	}

	foreach my $z ($visible->{Z}->{MIN}..$visible->{Z}->{MAX}){
		my $level = ${$map}[$z];
		print "\n\n\n------------ Z = $z --------------\n\n\n";
		foreach my $y ($visible->{Y}->{MIN}..$visible->{Y}->{MAX}){
			my $row = ${$level}[$y];
			foreach my $x ($visible->{X}->{MIN}..$visible->{X}->{MAX}){
				my $point = ${$row}[$x];
				if (!$point->{STARS}){
					print " ";
				}
				elsif(scalar(@{$point->{STARS}}) > 2){
					print "#";
				}
				elsif(scalar(@{$point->{STARS}}) == 2){
					print ":";
				}
				else { # one star
					print "*";
				}

			}
			print "\n";
		}
	}
}

sub GeneratePlanets {
	my ($args) = @_;
	die "Star required!" unless($args->{STAR});
	my @planets = ();
	my $firstgasgiant;
	my $planet_arrangement;
	my $firstroll = roll '3d6';
	if ($firstroll <= 10){
		#No gas giant but we still need the orbital radius for the first planet
		#Roll 1d, multiply by 0.05, add 1, and divide the outermost legal distance by the result.
		$firstgasgiant->{ORBITALRADIUS} = $args->{STAR}->{OUTERLIMIT} / ((roll '1d6') * 0.05 + 1);
		$planet_arrangement = 'NO_GAS_GIANT';
	}
	elsif($firstroll <= 12){
		my $secondroll = roll '2d6-2';
		$firstgasgiant->{ORBITALRADIUS} = (1 + 0.05 * $secondroll) * $args->{STAR}->{SNOWLINE};
		$planet_arrangement = 'CONVENTIONAL_GAS_GIANT';
	}
	elsif ($firstroll <= 14){
		my $secondroll = roll '1d6';
		$firstgasgiant->{ORBITALRADIUS} = (0.125 * $secondroll) * $args->{STAR}->{SNOWLINE};
		$planet_arrangement = 'ECCENTRIC_GAS_GIANT';

	}
	else {
		my $secondroll = roll '2d6';
		$firstgasgiant->{ORBITALRADIUS} = (0.1 * $secondroll) * $args->{STAR}->{INNERLIMIT};
		$planet_arrangement = 'EPISTELLAR_GAS_GIANT';
	}
	#TODO: need to move Gas giants out of forbidden zones if they exist...
	my $orbits = DetermineOrbits({
		STAR => $args->{STAR},
		FIRSTRADIUS => $firstgasgiant->{ORBITALRADIUS},
	});

	# First place Gas Giants
	my $index = 0;
	foreach my $orbit (sort { $a->{ORBITALRADIUS} <=> $b->{ORBITALRADIUS} } @$orbits){
		$orbit->{INDEX} = $index++;
		if($orbit->{ORBITALRADIUS} == $firstgasgiant->{ORBITALRADIUS} && $planet_arrangement ne ''){
			my $gasgiant = CreateGasGiant({
				STAR => $args->{STAR},
				CURRENTORBIT => $orbit->{ORBITALRADIUS},
			});
			$orbit->{PLANET} = $gasgiant;
		}
		else{
			my $gg_exists_roll = roll '3d6';
			if($orbit->{ORBITALRADIUS} < $args->{STAR}->{SNOWLINE}){
				if($gg_exists_roll < 8 && $planet_arrangement eq 'ECCENTRIC_GAS_GIANT' || $gg_exists_roll < 6 && $planet_arrangement eq 'EPISTELLAR_GAS_GIANT'){
					my $gasgiant = CreateGasGiant({
						STAR => $args->{STAR},
						CURRENTORBIT => $orbit->{ORBITALRADIUS},
					});
					$orbit->{PLANET} = $gasgiant;
				}
			}
			else {
				if(
					$gg_exists_roll < 15 && $planet_arrangement eq 'CONVENTIONAL_GAS_GIANT' 
					|| $gg_exists_roll < 14 && $planet_arrangement eq 'ECCENTRIC_GAS_GIANT' 
					|| $gg_exists_roll < 14 && $planet_arrangement eq 'EPISTELLAR_GAS_GIANT'
				){
					my $gasgiant = CreateGasGiant({
						STAR => $args->{STAR},
						CURRENTORBIT => $orbit->{ORBITALRADIUS},
					});
					$orbit->{PLANET} = $gasgiant;
				}
			}
		};
	}
	# Iterate through again, but specifically in order of closest to farthest
	foreach my $orbit (sort { $b->{ORBITALRADIUS} <=> $a->{ORBITALRADIUS} } @$orbits){
		next if ($orbit->{PLANET}); # Skip it if we already 
		my $modifier = 0;
		my $nextplanet = FindPlanetAtIndex({
			INDEX => $orbit->{INDEX} + 1,
			ORBITS => $orbits,
		});
		my $previousplanet = FindPlanetAtIndex({
			INDEX => $orbit->{INDEX} - 1,
			ORBITS => $orbits,
		});
		#print "Prev: ". Dumper($previousplanet);
		#print "Next: ". Dumper($nextplanet);
		$modifier -= 6 if ($nextplanet && $nextplanet->{TYPE} eq 'GAS GIANT');
		$modifier -= 3 if ($previousplanet && $previousplanet->{TYPE} eq 'GAS GIANT');
		$modifier -= 3 if ($orbit->{INDEX} == 0) || ($orbit->{INDEX} == (scalar(@{$orbits}) -1) );
		my $fill_type = ConvertRollToOutput({
			NUMDICE => 3,
			MODIFIER => $modifier,
			RESULTARRAY => [
				[-100, 3, {TYPE => "EMPTY"} ],
				[4, 6, {TYPE => "ASTEROID BELT"}],
				[7, 8, {TYPE => "TERRESTRIAL", SIZE => "TINY"}],
				[9, 11, {TYPE => "TERRESTRIAL", SIZE => "SMALL"}],
				[12, 15, {TYPE => "TERRESTRIAL", SIZE => "STANDARD"}],
				[16, 99, {TYPE => "TERRESTRIAL", SIZE => "LARGE"}],
			],
		});
		if($fill_type->{TYPE} eq 'TERRESTRIAL'){
			$orbit->{PLANET} = CreateTerrestrialPlanet({
				SIZE => $fill_type->{SIZE},
				ORBITALRADIUS => $orbit->{ORBITALRADIUS},
				STAR => $args->{STAR},
			});
		}
		else {
			#print "Fill Type:". Dumper($fill_type);
			$orbit->{PLANET} = $fill_type;
		}
	}
	return $orbits;
}

sub FindPlanetAtIndex {
	my ($args) = @_;
	my $index = $args->{INDEX};
	my @orbits = @{$args->{ORBITS}};
	my ($planet) = grep { $_->{INDEX} == $index } @orbits;
	#print "Find:". Dumper($planet);
	return $planet->{PLANET};
}

sub CreateTerrestrialPlanet {
	my ($args) = @_;
	my $planet = {
		TYPE => 'TERRESTRIAL',
		ORBITALRADIUS => $args->{ORBITALRADIUS},
		SIZE => $args->{SIZE},
	};
	$planet->{MOONS} = GenerateMoons({ SIZE => $planet->{SIZE}, ORBITALRADIUS => $planet->{ORBITALRADIUS}, STAR => $args->{STAR}, TYPE => 'TERRESTRIAL' });
	$planet->{BLACKBODYTEMPERATURE} = BlackBodyRadiation({PLANET => $planet, STAR => $args->{STAR}});
	$planet->{SUBTYPE} = DetermineTerrestrialSubtype({PLANET => $planet, STAR => $args->{STAR}});
	$planet->{ATMOSPHERE} = DetermineAtmosphere({PLANET => $planet, STAR => $args->{STAR}});
	$planet->{LIQUIDCOVERAGE} = DetermineLiquidCoverage({PLANET => $planet});
	return $planet;
}
sub DetermineLiquidCoverage {
	my ($args) = @_;
	my $planet = $args->{PLANET};
	my $watercoverage = 0;
	if ($planet->{SUBTYPE} eq 'ICE' && $planet->{SIZE} eq 'SMALL'){
		$watercoverage = (roll '1d6+2') * 10 + (roll '1d10-1'); 
	}
	elsif($planet->{SUBTYPE} eq 'ICE' && $planet->{SIZE} ne 'TINY'){
		$watercoverage = (roll '2d-10') * 10 + (roll '1d10-1');
	}
	elsif($planet->{SUBTYPE} eq 'GARDEN' || $planet->{SUBTYPE} eq 'OCEAN'){
		if($planet->{SIZE} eq 'LARGE'){
			$watercoverage = (roll '1d6+6') * 10 + (roll '1d10-1');
		}
		elsif($planet->{SIZE} eq 'STANDARD'){
			$watercoverage = (roll '1d6+4') * 10 + (roll '1d10-1');
		}
	}
	elsif($planet->{SUBTYPE} eq 'GREENHOUSE'){
		my $dryworld = 0;
		foreach my $gas (@{$planet->{ATMOSPHERE}->{COMPOSITION}}){
			if($gas eq 'CARBON DIOXIDE'){
				$dryworld = 1;
			}
		}
		if ($dryworld){
			$watercoverage = 0;
		}
		else {
			$watercoverage = (roll '2d6-7') * 10 + (roll '1d10-1');
			$watercoverage = 10 if $watercoverage < 10;
		}
	}
	elsif($planet->{SUBTYPE} eq 'AMMONIA') {
		$watercoverage = (roll '2d') * 10 + (roll '1d10-1');
	}
	$watercoverage = 100 if $watercoverage > 100;
	$watercoverage = 0 if $watercoverage < 0;
	return $watercoverage;
}

sub DetermineTerrestrialSubtype {
	my ($args) = @_;
	my $planet = $args->{PLANET};
	my $star = $args->{STAR};
	if($planet->{SIZE} eq 'TINY'){
		if($planet->{BLACKBODYTEMPERATURE} < 141){
			return "ICE";
		}
		else {
			return "ROCK";
		}
	}
	elsif($planet->{SIZE} eq 'SMALL'){
		if($planet->{BLACKBODYTEMPERATURE} < 81){
			return "HADEAN";
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 141){
			return "ICE";
		}
		else {
			return "ROCK";
		}
	}
	elsif($planet->{SIZE} eq 'STANDARD'){
		if($planet->{BLACKBODYTEMPERATURE} < 81){
			return "HADEAN";
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 151){
			return "ICE";
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 241){
			if($star->{MASS} < .65){
				return "AMMONIA";
			}
			else {
				return "ICE";
			}
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 321){
			my $rollforgarden = roll '3d6';
			my $modifier += int($star->{AGE} / 2);
			$modifier = 10 if ($modifier > 10);
			$rollforgarden += $modifier;
			if($rollforgarden >= 18){
				return "GARDEN";
			}
			else {
				return "OCEAN";
			}
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 501){
			return "GREENHOUSE";
		}
		else {
			return "CHTHONIAN";
		}
	}
	elsif($planet->{SIZE} eq 'LARGE'){
		if ($planet->{BLACKBODYTEMPERATURE} < 151){
			return "ICE";
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 231){
			if($star->{MASS} < .65){
				return "AMMONIA";
			}
			else {
				return "ICE";
			}
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 241){
			return "ICE";
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 321){
			my $rollforgarden = roll '3d6';
			my $modifier += int($star->{AGE} / 2);
			$modifier = 5 if ($modifier > 5);
			$rollforgarden += $modifier;
			if($rollforgarden >= 18){
				return "GARDEN";
			}
			else {
				return "OCEAN";
			}
		}
		elsif ($planet->{BLACKBODYTEMPERATURE} < 501){
			return "GREENHOUSE";
		}
		else {
			return "CHTHONIAN";
		}
	}
}
sub CreateGasGiant {
	my ($args) = @_;
	my $modifier = 0;
	my $gg = {
		ORBITALRADIUS => $args->{CURRENTORBIT},
		TYPE => 'GAS GIANT',
	};
	if ($args->{CURRENTORBIT} < $args->{STAR}->{SNOWLINE}){
		$modifier = 4;
	}
	#Determine size
	$gg->{SIZE} = ConvertRollToOutput({
		NUMDICE => 3,
		MODIFIER => $modifier,
		RESULTARRAY => [
			[3, 10, 'SMALL'],
			[11, 16, 'STANDARD'],
			[17, 99, 'LARGE'],
		],
	});
	# Add moons
	$gg->{MOONS} = GenerateMoons({ TYPE => 'GAS GIANT', ORBITALRADIUS => $gg->{ORBITALRADIUS}, STAR => $args->{STAR} });
	return $gg;
}

sub GenerateMoons {
	my ($args) = @_;
	my $type = $args->{TYPE};
	my $size = $args->{SIZE};
	my $orbitalradius = $args->{ORBITALRADIUS};
	my @moons = ();
	if ($type eq 'GAS GIANT'){
		#moonlets
		my $modifier = 0;
		if($orbitalradius < 0.1){
			$modifier = -10;
		}
		elsif($orbitalradius < 0.5){
			$modifier = -8;
		}
		elsif($orbitalradius < 0.75){
			$modifier = -6;
		}
		elsif($orbitalradius < 1.5){
			$modifier = -3;
		}
		my $moonlets = ( roll '2d6' )+ $modifier;
		$moonlets = 0 if ($moonlets < 0);
		push(@moons, "$moonlets MOONLETS") if $moonlets;
		#major moons
		$modifier = 0;
		if($orbitalradius < 0.1){
			$modifier = -10; # it says don't roll, but -10 is the same effect for 1d
		}
		elsif($orbitalradius < 0.5){
			$modifier = -5;
		}
		elsif($orbitalradius < 0.75){
			$modifier = -4;
		}
		elsif($orbitalradius < 1.5){
			$modifier = -1;
		}
		my $major_moons = ( roll '1d6' ) + $modifier;
		$major_moons = 0 if ($major_moons < 0);
		for (my $i = 0 ;$i < $major_moons; $i++){
			my $moonsize = MoonSize({ SIZE => 'LARGE' });
			my $moon = CreateTerrestrialPlanet({ORBITALRADIUS => $orbitalradius, STAR => $args->{STAR}, SIZE => $moonsize});
			push (@moons, $moon);
		}
		#captured asteroids
		$modifier = 0;
		if($orbitalradius < 0.5){
			$modifier = -10; # it says don't roll, but -10 is the same effect for 1d
		}
		elsif($orbitalradius < 0.75){
			$modifier = -5;
		}
		elsif($orbitalradius < 1.5){
			$modifier = -4;
		}
		elsif($orbitalradius < 3){
			$modifier = -1;
		}
		my $captured_asteroids = (roll '1d6') + $modifier;
		$captured_asteroids = 0 if ($captured_asteroids < 0);
		push(@moons, "$captured_asteroids CAPTURED ASTEROIDS") if $captured_asteroids;
	}
	elsif ( $type eq 'TERRESTRIAL' ){
		my $modifier = 0;
		#distance
		if($orbitalradius < 0.5){
			$modifier = -10; # it says don't roll, but -10 is the same effect for 1d
		}
		elsif($orbitalradius < 0.75){
			$modifier = -3;
		}
		elsif($orbitalradius < 1.5){
			$modifier = -1;
		}
		#size
		if ($size eq 'TINY'){
			$modifier -= 2;
		}
		elsif($size eq 'SMALL'){
			$modifier -= 1;
		}
		elsif($size eq 'LARGE'){
			$modifier += 1;
		}
		my $major_moons = ( roll '1d6' ) + $modifier - 4;
		$major_moons = 0 if ($major_moons < 0);
		for (my $i = 0 ;$i < $major_moons; $i++){
			my $moonsize = MoonSize({ SIZE => $size });
			my $moon = CreateTerrestrialPlanet({ORBITALRADIUS => $orbitalradius, STAR => $args->{STAR}, SIZE => $moonsize});
			#print "planet Size: $size\n";
			#print "Moon Size: $moonsize\n";
			push (@moons, $moon);
			#print "Moons:". Dumper(\@moons);
		}
		if($major_moons == 0){
			my $moonlets = ( roll '1d6' ) - 2 + $modifier;
			$moonlets = 0 if ($moonlets < 0);
			push(@moons, "$moonlets MOONLETS") if ($moonlets);
		}
	}
	return \@moons;
}

sub DetermineAtmosphere {
	my ($args) = @_;
	my $planet = $args->{PLANET};
	my $star = $args->{STAR};
	# Handle all types that have no atmosphere first
	if(
		$planet->{SIZE} eq 'TINY' 
		|| $planet->{SUBTYPE} eq 'CHTHONIAN' 
		|| $planet->{SUBTYPE} eq 'HADEAN'
		|| ($planet->{SIZE} eq 'SMALL' && $planet->{SUBTYPE} eq 'ROCK')
	){
		return {
			COMPOSITION => [],
			DESCRIPTORS => [],
			ATMOSPHERICMASS => 0.0,
		};
	}
	# Normal case 
	my $atmo_mass = (roll '3d6') / (10.0);
	my $composition= [];
	my $descriptors = [];
	if ($planet->{SUBTYPE} eq 'ICE' || $planet->{SUBTYPE} eq 'OCEAN'){
		my $roll = roll '3d6';
		if($planet->{SIZE} eq 'SMALL' && $roll < 15){
			$descriptors = ['SUFFOCATING', 'MILDLY TOXIC'];
			$composition = ['METHANE', 'NITROGEN'];
		}
		elsif($planet->{SIZE} eq 'SMALL'){
			$descriptors = ['SUFFOCATING', 'HIGHLY TOXIC'];
			$composition = ['METHANE', 'NITROGEN'];
		}
		elsif($planet->{SIZE} eq 'STANDARD' && $roll < 12){
			$descriptors = ['SUFFOCATING'];
			$composition = ['CARBON DIOXIDE', 'NITROGEN'];
		}
		elsif($planet->{SIZE} eq 'STANDARD'){
			$descriptors = ['SUFFOCATING', 'MILDLY TOXIC'];
			my $othergas = (roll '1d2' == 1 ? 'SULFUR DIOXIDE' : 'METHANE');
			$composition = ['CARBON DIOXIDE', 'NITROGEN', $othergas];
		}
		elsif($planet->{SIZE} eq 'LARGE'){
			$descriptors = ['SUFFOCATING', 'HIGHLY TOXIC'];
			my $othergas = (roll '1d2' == 1 ? 'SULFUR DIOXIDE' : 'METHANE');
			$composition = ['HELIUM', 'NITROGEN', $othergas];
		}
	}
	if ($planet->{SUBTYPE} eq 'AMMONIA'){
		if($planet->{SIZE} eq 'STANDARD'){
			$descriptors = ['SUFFOCATING', 'LETHALLY TOXIC', 'CORROSIVE'];
			$composition = ['NITROGEN', 'AMMONIA', 'METHANE' ];
		}
		elsif($planet->{SIZE} eq 'LARGE'){
			$descriptors = ['SUFFOCATING', 'LETHALLY TOXIC', 'CORROSIVE'];
			$composition = ['HELIUM', 'AMMONIA', 'METHANE' ];
		}
	}
	if ($planet->{SUBTYPE} eq 'GARDEN'){
		my $roll = roll '3d6';
		$composition = ['NITROGEN', 'OXYGEN'];
		if($roll > 11){
			my $marginal_component = ConvertRollToOutput({
				NUMDICE => 3,
				RESULTARRAY => [
					[3, 4, 'CHLORINE OR FLUORINE'],
					[5, 6, 'SULFUR COMPOUNDS'],
					[7, 7, 'NITROGEN COMPOUNDS'],
					[8, 9, 'ORGANIC TOXINS'],
					[10, 11, 'LOW OXYGEN'],
					[12, 13, 'POLLUTANTS'],
					[14, 14, 'HIGH CARBON DIOXIDE'],
					[15, 16, 'HIGH OXYGEN'],
					[17, 18, 'INERT GASES'],
				],
			});
			push(@$descriptors, $marginal_component);
			if($marginal_component eq 'CHLORINE OR FLUORINE'){
				my $othergas = (roll '3d6' == 3 ? 'FLUORINE' : 'CHLORINE');
				push(@$composition, $othergas);
				push(@$descriptors, 'LETHALLY TOXIC', 'CORROSIVE');
			}
			elsif($marginal_component eq 'NITROGEN COMPOUNDS' || $marginal_component eq 'HIGH CARBON DIOXIDE' || $marginal_component eq 'HIGH OXYGEN' || $marginal_component eq 'SULFUR COMPOUNDS'){
				push(@$descriptors, 'MILDLY TOXIC');
			}
			elsif($marginal_component eq 'ORGANIC TOXINS' || $marginal_component eq 'POLLUTANTS'){
				my $howtoxic = ConvertRollToOutput({
					NUMDICE => 3,
					RESULTARRAY => [
						[3, 6, ''],
						[7, 16, 'MILDLY TOXIC'],
						[17, 18, 'HIGHLY TOXIC'],
					],
				});
				push(@$descriptors, $howtoxic) if $howtoxic;
			}
		}
	}
	if ($planet->{SUBTYPE} eq 'GREENHOUSE'){
		$descriptors = ['SUFFOCATING', 'LETHALLY TOXIC', 'CORROSIVE'];
		if (roll '3d6' < 11){
			$composition = ['NITROGEN', 'WATER VAPOR'];
		}
		else{
			$composition = ['CARBON DIOXIDE'];
		}
	}
	return {
		COMPOSITION => $composition,
		DESCRIPTORS => $descriptors,
		ATMOSPHERICMASS => $atmo_mass,
	};
}

sub BlackBodyRadiation {
	my ($args) = @_;
	my $planet = $args->{PLANET};
	my $star = $args->{STAR};
	my $b = 278 * sqrt(sqrt($star->{LUMINOSITY}))/sqrt($planet->{ORBITALRADIUS});
	return $b;
}
sub MoonSize {
	my ($args) = @_;
	my $sizemodifier = ConvertRollToOutput({
		NUMDICE => 3,
		RESULTARRAY => [
			[0, 11, -3],
			[12, 14, -2],
			[15, 100, -1],
		],
	});
	#print "Size Modifier: $sizemodifier\n";
	my $planet_size_index = first { $SIZE_LIST[$_] eq $args->{SIZE} } 0..$#SIZE_LIST;
	my $moon_size_index = $planet_size_index + $sizemodifier;
	$moon_size_index = 0 if $moon_size_index < 0;
	return $SIZE_LIST[$moon_size_index];
}
sub DetermineOrbits {
	my ($args) = @_;
	my $orbitalspacing = DetermineOrbitalSpacing();
	my @orbits;
	# work inward and then outward
	my $current_orbit = $args->{FIRSTRADIUS};
	while ($current_orbit > $args->{STAR}->{INNERLIMIT}){
		push(@orbits, {ORBITALRADIUS => $current_orbit});
		$current_orbit = $current_orbit / $orbitalspacing;
	}
	$current_orbit = $args->{FIRSTRADIUS} * $orbitalspacing;
	while ($current_orbit < $args->{STAR}->{OUTERLIMIT}){
		push(@orbits, {ORBITALRADIUS => $current_orbit});
		$current_orbit = $current_orbit * $orbitalspacing;
	}
	return \@orbits;
}

sub DetermineOrbitalSpacing {
	return ConvertRollToOutput({
		NUMDICE => 3,
		RESULTARRAY => [
			[3, 4, 1.4],
			[5, 6, 1.5],
			[7, 8, 1.6],
			[9, 12, 1.7],
			[13, 14, 1.8],
			[15, 16, 1.9],
			[17, 18, 2.0],
		],
	});
}

sub NewPrimaryStellarMass{
	my $firstroll = roll '3d6';
	my $secondroll = roll '3d6';
	if($firstroll == 3){
		if($secondroll == 3){
			my $thirdroll = roll '3d6';
			if ($thirdroll == 3){
				return 10.0;
			}
			elsif($thirdroll == 4){
				return 7.5;
			}
			elsif ($thirdroll == 5){
				return 5.0;
			}
			else {
				return 3.0;
			}
		}
		elsif ($secondroll <= 10) {
			return 2.0;
		}
		else {
			return 1.9;
		}
	} # end firstroll == 3
	elsif ($firstroll == 4){
		if($secondroll <= 8 ){
			return 1.8;
		}
		elsif($secondroll <= 11){
			return 1.7;
		}
		else {
			return 1.6;
		}
	} # end firstroll == 4
	elsif ($firstroll == 5){
		if($secondroll <= 7 ){
			return 1.5;
		}
		elsif($secondroll <= 10){
			return 1.45;
		}
		elsif($secondroll <= 12){
			return 1.4;
		}
		else {
			return 1.35;
		}
	} # end firstroll = 5
	elsif ($firstroll == 6){
		if($secondroll <= 7 ){
			return 1.3;
		}
		elsif($secondroll <= 9){
			return 1.25;
		}
		elsif($secondroll <= 10){
			return 1.2;
		}
		elsif($secondroll <= 12){
			return 1.15;
		}
		else {
			return 1.1;
		}
	} # end firstroll = 6
	elsif ($firstroll == 7){
		if($secondroll <= 7 ){
			return 1.05;
		}
		elsif($secondroll <= 9){
			return 1.00;
		}
		elsif($secondroll <= 10){
			return 0.95;
		}
		elsif($secondroll <= 12){
			return 0.90;
		}
		else {
			return 0.85;
		}
	} # end firstroll = 7
	elsif ($firstroll == 8){
		if($secondroll <= 7 ){
			return 0.80;
		}
		elsif($secondroll <= 9){
			return 0.75;
		}
		elsif($secondroll <= 10){
			return 0.70;
		}
		elsif($secondroll <= 12){
			return 0.65;
		}
		else {
			return 0.60;
		}
	} # end firstroll = 8
	elsif ($firstroll == 9){
		if($secondroll <= 8 ){
			return 0.55;
		}
		elsif($secondroll <= 11){
			return 0.50;
		}
		else {
			return 0.45;
		}
	} # end firstroll = 9
	elsif ($firstroll == 10){
		if($secondroll <= 8 ){
			return 0.40;
		}
		elsif($secondroll <= 11){
			return 0.35;
		}
		else {
			return 0.30;
		}
	} # end firstroll = 10
	elsif ($firstroll == 11){
		return 0.25;
	}
	elsif ($firstroll == 12){
		return 0.20;
	}
	elsif ($firstroll == 13){
		return 0.15;
	}
	else {
		return 0.10;
	}
}

sub NewCompanionStellarMass {
	my ($args) = @_;
	die "Main star mass required!" unless ($args->{MAINSTARMASS});

	my $mainstarmass = $args->{MAINSTARMASS};
	if ($mainstarmass > 2.0){
		$mainstarmass = 2.0;
	}
	my $roll = roll '1d6';
	$roll -= 1;
	if($roll == 0) {
		return $mainstarmass;
	}
	else {
		my $secondroll = roll "${roll}d6";
		if ($mainstarmass >= 1.6){
			$secondroll -= (($mainstarmass -1.5) * 10);
		}
		my $companionmass;
		if($secondroll <= 0){
			$companionmass = ($mainstarmass - ($secondroll * 0.1));
		}
		else {
			$companionmass = ($mainstarmass - ($secondroll * 0.05));
		}

		if ($companionmass < 0.1){
			$companionmass = 0.1;
		}

		return $companionmass;
	}
}

sub StarSystemAge {
	my ($args) = @_;
	my $firstroll = roll '3d6';
	my $secondroll = roll '1d6-1';
	my $thirdroll = roll '1d6-1';
	my $base;
	my $a;
	my $b;
	if($firstroll <= 3){
		($base, $a, $b) = qw(0 0 0);
	}
	elsif($firstroll <= 6){
		($base, $a, $b) = qw(0.1 0.3 0.05);
	}
	elsif($firstroll <= 10){
		($base, $a, $b) = qw(2 0.6 0.1);
	}
	elsif($firstroll <= 14){
		($base, $a, $b) = qw(5.6 0.6 0.1);
	}
	elsif($firstroll <= 17){
		($base, $a, $b) = qw(8 0.6 0.1);
	}
	else {
		($base, $a, $b) = qw(10 0.6 0.1);
	}
	my $age = $base + ($secondroll * $a) + ($thirdroll * $b);

	return $age;
}
sub _PrettyPrintHashref {
	my ($hashref, $numtabs) = @_;
	my $string = "";
	foreach my $sub_key (sort keys %{$hashref}){
		if(ref $hashref->{$sub_key} eq 'ARRAY'){
			$string .=  ("\t" x ($numtabs + 1 ) ) . "$sub_key: ".join(", ", @{$hashref->{$sub_key}})."\n";
		}
		elsif(ref $hashref->{$sub_key} eq 'HASH'){
			$string .= _PrettyPrintHashref($hashref->{$sub_key}, ($numtabs +1));
		}
		else {
			$string .=  ("\t" x ($numtabs + 1 ) ) . "$sub_key: $hashref->{$sub_key}\n";
		}
	}
	return $string;
}
sub _PrettyPrintPlanet {
	my ($planet, $numtabs, $index) = @_;
	my $string = ("\t" x ($numtabs -1 ) ) . "Number $index:\n";
	foreach my $key (sort keys %{$planet->{PLANET}}){
		next if $key eq 'MOONS';
		if(ref $planet->{PLANET}->{$key} eq 'HASH'){
			$string .=  ("\t" x ($numtabs ) ) . "$key\n";
			my $hashref = $planet->{PLANET}->{$key};
			$string .= _PrettyPrintHashref($hashref, $numtabs);
		}
		else{
			$string .= ("\t" x $numtabs) . "$key:$planet->{PLANET}->{$key}\n";
		}
	}
	if($planet->{PLANET}->{MOONS} && @{$planet->{PLANET}->{MOONS}}){ $string .= ("\t" x $numtabs) . "Moons:\n" };
	my $moonindex=0;
	foreach my $moon (@{$planet->{PLANET}->{MOONS}}){
		if(ref $moon eq 'HASH'){
			$string .= _PrettyPrintPlanet({ PLANET => $moon}, $numtabs +2, $moonindex);
		}
		else{
			$string .= ("\t" x ($numtabs+1) )."$moon\n";
		}
		$moonindex++;
	}
	return $string;
}
sub PrettyPrintString {
	my ($args) = @_;
	my $system = $args->{SYSTEM};
	my $string = "System:\n";
	foreach my $star (@{$system->{STARS}}){
		$string .= "\tStar:\n";
		foreach my $key (sort keys %$star){
			next if $key eq 'PLANETS';
			$string .= "\t\t$key:$star->{$key}\n";
		}
		$string .= "\t\tPlanets:\n";
		foreach my $planet (sort { $a->{INDEX} <=> $b->{INDEX} } @{$star->{PLANETS}}){
			$string .= _PrettyPrintPlanet($planet, 4, $planet->{INDEX});
		}
	}
	return $string;
}

sub StarLuminosity {
	my ($args) = @_;
	die 'Mass and Age required!' unless (defined $args->{MASS} && defined $args->{AGE});
	my $class;
	my $luminosity;

	my ($type, $temp, $lmin, $lmax, $mspan, $sspan, $gspan) = @{ $LUMINOSITYCHART{ $args->{MASS} } };
	if ($lmax eq '-'){
		$lmax = $lmin;
	}
	if ($mspan eq '-' || $args->{AGE} <= $mspan){
		$class = 'V';
		if ($mspan eq '-'){
			$luminosity = $lmin;
		}
		else {
			$luminosity = $lmin + (($args->{AGE}/$mspan) * ($lmax - $lmin));
		}
	}
	elsif ($sspan eq '-'){
		$class = 'D';
	}
	elsif($args->{AGE} <= ($mspan + $sspan)){
		$class = 'IV';
		$luminosity = $lmax;
		$temp = $temp - (($args->{AGE} - $mspan)/$sspan) * ($temp - 4800);
		my @newtyperow = grep { ${$_}[1] <= $temp + 100 && ${$_}[1] >= $temp - 100 } values %LUMINOSITYCHART;
		if (scalar(@newtyperow) == 0 ){
			print "Can't find Temp: $temp!\n";
		}
		$type = $newtyperow[0][0];
	}
	elsif($args->{AGE} <= ($mspan + $sspan + $gspan)){
		$class = 'III';
		$luminosity = 25 * $lmax;
		my $roll = roll '2d6-2';
		$temp = 3000 + ($roll * 200);
		my @newtyperow = grep { ${$_}[1] <= $temp + 100 && ${$_}[1] >= $temp - 100 } values %LUMINOSITYCHART;
		if (scalar(@newtyperow) == 0 ){
			print "Can't find Temp: $temp!\n";
		}
		$type = $newtyperow[0][0];
	}
	else {
		$class = 'D';
	}
	if ($class eq 'D'){
		my $roll = roll '2d6-2';
		$args->{MASS} = 0.9 + ($roll * 0.05);
		$luminosity = 0.001;
	}
	my $roll = roll '2d6-7';
	$luminosity = $luminosity * (1 + ($roll * 0.02));
	my $radius = (155_000 * sqrt($luminosity))/($temp**2);
	my $snowline = 4.85 * sqrt($lmin);
	return {
		TYPE => $type,
		TEMP => $temp,
		LUMINOSITY => $luminosity,
		CLASS => $class,
		RADIUS => $radius,
		SNOWLINE => $snowline,
	};
}

1;
use Test::More 0.88;
use Games::Dice::Loaded;

my $d4 = Games::Dice::Loaded->new(1, 1, 1, 1);
is($d4->num_sides, 4, "Fair d4 has four sides");

my @rolls;
for my $i (0 .. 4000) {
	my $roll = $d4->roll;
	ok($roll >= 1, "Roll >= 1");
	ok($roll <= 4, "Roll <= 4");
	$rolls[$roll]++;
}

done_testing;

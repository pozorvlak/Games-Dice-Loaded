use Test::More 0.88;
use Games::Dice::Loaded;

my $die = Games::Dice::Loaded->new(1, 2, 1, 7, 3, 5);
is($die->num_faces, 6, "Die has six faces");

my @rolls;
for my $i (0 .. 4000) {
	my $roll = $die->sample;
	cmp_ok($roll, '>=', 1, "Roll >= 1");
	cmp_ok($roll, '<=', 6, "Roll <= 6");
	$rolls[$roll]++;
}

done_testing;

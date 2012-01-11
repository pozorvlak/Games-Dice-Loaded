use Test::More 0.88;
use Test::Probability;
use Games::Dice::Loaded;

my @weights = (1, 2, 1, 7, 3, 5);
my $die = Games::Dice::Loaded->new(@weights);
is($die->num_faces, 6, "Die has six faces");

my @rolls;
for my $i (0 .. 10000) {
	my $roll = $die->sample;
	cmp_ok($roll, '>=', 1, "Roll >= 1");
	cmp_ok($roll, '<=', 6, "Roll <= 6");
	$rolls[$roll]++;
}

dist_ok(\@rolls, \@weights, 0.9, "Loaded d6 matches distribution");

done_testing;

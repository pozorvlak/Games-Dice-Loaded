use Test::More 0.88;
use Games::Dice::Loaded;

# Plato woz ere
my $die = Games::Dice::Loaded->new(1/6, 1/6, 1/2, 1/12, 1/12);
is $die->num_sides, 5, "Die has one side per weight";
my @rolls;
for my $i (0 .. 12000) {
	my $roll = $die->roll;
	ok $roll >= 1, "Roll $roll >= 1";
	ok $roll <= 5, "Roll $roll <= 5";
	$rolls[$roll]++;
}
print "@rolls\n";

done_testing;

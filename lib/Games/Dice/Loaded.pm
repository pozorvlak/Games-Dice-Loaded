package Games::Dice::Loaded;
use Moose;
use List::Util 'max';
use Carp;

# ABSTRACT: Perl extension to simulate rolling loaded dice

has 'dartboard' => ( is => 'ro', isa => 'ArrayRef' );
has 'aliases' => ( is => 'ro', isa => 'ArrayRef' );
has 'num_sides' => ( is => 'ro', isa => 'Num' );

around BUILDARGS => sub {
	my $orig = shift;
	my $class = shift;
	# scale so average weight is 1
	my @weights = @_;
	my $n = scalar @weights;
	my $i = 0;
	@weights = map { [$i++, $n * $_] } @weights; 
	my @small = grep { $_->[1] < 1 } @weights;
	my @large = grep { $_->[1] >= 1 } @weights;
	my @dartboard; my @aliases;
	while ((@small > 0) && (@large > 0)) {
		my ($small_id, $small_p) = @{pop @small};
		my ($large_id, $large_p) = @{pop @large};
		$dartboard[$small_id] = $small_p;
		$aliases[$small_id] = $large_id;
		$large_p = $small_p + $large_p - 1;
		if ($large_p >= 1) {
			push @large, [$large_id, $large_p];
		} else {
			push @small, [$large_id, $large_p];
		}
	}
	for my $unused (@small, @large) {
		$dartboard[$unused->[0]] = 1;
		$aliases[$unused->[0]] = $unused->[0];
	}
	for my $side (0 .. $n - 1) {
		my $d = $dartboard[$side];
		croak("Undefined dartboard for side $side") unless defined $d;
		croak("Height $d too large for side $side") unless $d <= 1;
		croak("Height $d too small for side $side") unless $d >= 0;
	}
	return $class->$orig(
		dartboard => \@dartboard,
		aliases => \@aliases,
		num_sides => $n,
	);
};

sub roll {
	my ($self) = @_;
	my $side = int(rand $self->num_sides);
	my $height = rand 1;
	my @dartboard = @{$self->dartboard()};
	croak("Dartboard undefined for side $side")
		unless defined $dartboard[$side];
	if ($height > $dartboard[$side]) {
		my @aliases = @{$self->aliases};
		return $aliases[$side];
	} else {
		return $side;
	}
}

1;


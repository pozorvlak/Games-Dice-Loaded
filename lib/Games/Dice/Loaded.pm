package Games::Dice::Loaded;
use Moose;
use List::Util 'max';

# ABSTRACT: Perl extension to simulate rolling loaded dice

has 'dartboard' => ( is => 'ro', isa => 'Array' );
has 'aliases' => ( is => 'ro', isa => 'Array' );
has 'num_sides' => ( is => 'ro', isa => 'Num' );

sub BUILD {
	my ( $self, $params ) = @_;
	# scale so average weight is 1
	my @weights = @$params;
	my $n = scalar @weights;
	my $max = max @weights;
	my $i = 0;
	@weights = map { [$i++, ($n * $_) / $max] } @weights; 
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
	$self->dartboard(@dartboard);
	$self->aliases(@aliases);
}

sub roll {
	my ($self) = @_;
	my $side = int(rand $self->num_sides);
	my $height = rand 1;
	my @dartboard = $self->dartboard();
	if ($height > $dartboard[$side]) {
		my @aliases = $self->aliases;
		return $aliases[$side];
	} else {
		return $side;
	}
}

1;


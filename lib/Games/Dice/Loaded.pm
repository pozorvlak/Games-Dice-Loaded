package Games::Dice::Loaded;
use Moose;
use List::Util 'max';
use Carp;

# ABSTRACT: Perl extension to simulate rolling loaded dice

# Keith Schwarz's article is lovely and has lots of pretty diagrams and proofs,
# but unfortunately it's also very long. Here's the tl;dr:

# Draw a bar chart of the probabilities of landing on the various sides, then
# throw darts at it (by picking X and Y coordinates uniformly at random). If
# you hit a bar with your dart, choose that side. This works OK, but has very
# bad worst-case behaviour; fortunately, it's possible to cut up the taller
# bars and stack them on top of the shorter bars in such a way that the area
# covered is exactly a (1/n) \* n rectangle. Constructing this rectangular
# "dartboard" can be done in O(n) time, by maintaining a list of short (less
# than average height) bars and a list of long bars; add the next short bar to
# the dartboard, then take enough of the next long bar to fill that slice up to
# the top. Add the index of the long bar to the relevant entry of the "alias
# table", then put the remainder of the long bar back into either the list of
# short bars or the list of long bars, depending on how long it now is.

# Once we've done this, simulating a dice roll can be done in O(1) time:
# Generate the dart's coordinates; which vertical slice
# did the dart land in, and is it in the shorter bar on the bottom or the
# "alias" that's been stacked above it?.

# Heights of the lower halves of the strips
has 'dartboard' => ( is => 'ro', isa => 'ArrayRef' );
# Identities of the upper halves of the strips
has 'aliases' => ( is => 'ro', isa => 'ArrayRef' );
has 'num_sides' => ( is => 'ro', isa => 'Num' );

# Construct the dartboard and alias table
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

# Roll the die
sub roll {
	my ($self) = @_;
	my $side = int(rand $self->num_sides);
	my $height = rand 1;
	my @dartboard = @{$self->dartboard()};
	croak("Dartboard undefined for side $side")
		unless defined $dartboard[$side];
	if ($height > $dartboard[$side]) {
		my @aliases = @{$self->aliases};
		return $aliases[$side] + 1;
	} else {
		return $side + 1;
	}
}

1;

__END__

=head1 NAME

Games::Dice::Loaded - Simulate rolling loaded dice

=head1 SYNOPSIS

  use Games::Dice::Loaded;

  my $die = Games::Dice::Loaded->new(1/6, 1/6, 1/2, 1/12, 1/12);
  my $result = $die->roll();

=head1 DESCRIPTION

C<Games::Dice::Loaded> allows you to simulate rolling arbitrarily-weighted dice
with arbitrary numbers of sides - or, more formally, to model any discrete
random variable which may take only finitely many values. It does this using
Vose's elegant I<alias method>, which is described in Keith Schwarz's article
L<Darts, Dice, and Coins: Sampling from a Discrete
Distribution|http://www.keithschwarz.com/darts-dice-coins/>.

=head1 METHODS

=over

=item new()

Constructor. Takes as arguments the probabilities of rolling each "side". This
method constructs the alias table, in O(num_sides) time.

=item roll()

Roll the die. Takes no arguments, returns a number in the range 1 .. num_sides. Takes O(1) time.

=item num_sides()

The number of sides on the die. Read-only.

=back

=head1 AUTHOR

Miles Gould, E<lt>mgould@cpan.orgE<gt>

=head1 CONTRIBUTING

Please fork
L<the GitHub repository|http://github.com/pozorvlak/Games-Dice-Loaded>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Miles Gould

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

Perl modules for rolling dice:
L<Games::Dice>,
L<Games::Dice::Advanced>,
L<Bot::BasicBot::Pluggable::Module::Dice>,
L<random>.

A Perl module for calculating probability distributions for dice rolls:
L<Games::Dice::Probability>.

Descriptions of the alias method:

=over

=item L<Darts, Dice, and Coins: Sampling from a Discrete
Distribution|http://www.keithschwarz.com/darts-dice-coins/>

=item L<Data structure for loaded dice?|http://stackoverflow.com/questions/5027757/data-structure-for-loaded-dice> on StackOverflow

=item L<Wikipedia article|http://en.wikipedia.org/wiki/Alias_method>

=back

=cut

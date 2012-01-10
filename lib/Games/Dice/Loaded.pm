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
L<Darts, Dice and Coins|http://www.keithschwarz.com/darts-dice-coins/>.

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

L<Games::Dice::Advanced>,
L<Games::Dice::Probability>,
L<Bot::BasicBot::Pluggable::Module::Dice>,
L<random>.

=cut

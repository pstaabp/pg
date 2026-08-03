#!/usr/bin/env perl

=head1 SignificantFigure context

Test the SignificantFigure context defined in contextSignificantFigure.pl.

=cut

use Test2::V0 '!E', { E => 'EXISTS' };

die "PG_ROOT not found in environment.\n" unless $ENV{PG_ROOT};
do "$ENV{PG_ROOT}/t/build_PG_envir.pl";

use lib "$ENV{PG_ROOT}/lib";

# load the Units module so that %Units::known_units is populated
use Units;
use Value;
require Parser::Legacy;
import Parser::Legacy;

loadMacros('contextSignificantFigures.pl', 'contextUnits.pl');

my $context = context::Units::extending("SignificantFigures")->withUnitsFor('length');

subtest 'Setup a basic Unit context extending SignificantFigures' => sub {
	Context($context);    # make it current without copying
	ok(defined $context && ref($context), 'Got a context object');
	is $context->{name}, 'Units-SignificantFigures', 'Context has correct name';
};

subtest 'Test a number with length units and significant figures' => sub {
	Context($context);
	ok my $a = Compute("123.0 cm"), 'Compute handles a unit.';

	is $a, '123.0 cm', 'Value stringifies with units and sig figs';
	ok $a == Compute('1.230 m'), 'Value stringifies with correct unit conversion and sig figs';
	ok $a != Compute('123 cm'),  'Value does not lose significant figure information when stringified';

	ok $a == Compute('4.035 ft'), 'Value in feet';
	ok $a == Compute('4.034 ft'), 'Value in feet (a little off, but when converted to m is correct)';
	ok $a == Compute('4.036 ft'), 'Value in feet (a little off, but when converted to m is correct)';
};

subtest 'Test an actual problem' => sub {

	my $source = <<~'END_SOURCE';
		DOCUMENT();

		loadMacros("PGstandard.pl","PGML.pl",'contextSignificantFiguresUnits.pl');

		Context('SignificantFiguresUnits')->withUnitsFor('mass');

		Context()->flags->set(
					tolerance                   => 0.01,
					partial_incorrect_sf        => 0.6,
					partial_sf_within_tolerance => 0.8,
					);

		$a = Compute("123.0 g");
		$b = Compute("45.3 g");
		$c = $a+$b;

		BEGIN_PGML
		A lab technician has a beaker with [$a] of water.  She adds [$b] to the beaker.  Using the proper number of significant figures, what is the total amount in the beaker? 

		[_]{$c}
		END_PGML

		ENDDOCUMENT();
	END_SOURCE

	ok my $pg = WeBWorK::PG->new(
		r_source       => \$source,
		inputs_ref     => { AnSwEr0001 => '168.3 g' },
		processAnswers => 1
		),
		'source string renders';

	is $pg->{result}{score}, 1, 'correct answer is scored correctly';

	my $pg2 = WeBWorK::PG->new(
		r_source       => \$source,
		inputs_ref     => { AnSwEr0001 => '168.30 g' },
		processAnswers => 1
	);

	is $pg2->{result}{score}, 0.6, 'check deduction for wrong number of significant figures.';
	like $pg2->{answers}{AnSwEr0001}{ans_message}, qr/Incorrect number of significant figures/,
		'Answer processed showing message.';

	my $pg3 = WeBWorK::PG->new(
		r_source       => \$source,
		inputs_ref     => { AnSwEr0001 => '168.2 g' },
		processAnswers => 1
	);

	is $pg3->{result}{score}, 0.8,
		'check deduction for right number of significant figures, but answer within tolerance.';
	like $pg3->{answers}{AnSwEr0001}{ans_message},
		qr/Correct number of significant figures, but the value is not correct/,
		'Answer processed showing message.';

};

done_testing;

use Test2::V0 '!E', { E => 'EXISTS' };

die "PG_ROOT not found in environment.\n" unless $ENV{PG_ROOT};
do "$ENV{PG_ROOT}/t/build_PG_envir.pl";

use lib "$ENV{PG_ROOT}/lib";

loadMacros('contextSignificantFigures.pl');

use Value;
require Parser::Legacy;
import Parser::Legacy;

use Data::Dumper;

Context('SignificantFigures');

subtest 'Entering sigfig in sci notation' => sub {
	my $a1 = Compute('1.0 x 10^2');
	is $a1->format('E'), '1.0E+02', 'Ensure that the internal storage of 1.0 * 10^2 is correct.';
};

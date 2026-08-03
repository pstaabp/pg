
BEGIN { strict->import }

loadMacros('contextUnits.pl', 'contextSignificantFigures.pl');

sub _contextSignificantFiguresUnits_init {
	context::SignificantFiguresUnits::Init(@_);
}

package context::SignificantFiguresUnits::NumberWithUnit;
our @ISA = ('context::Units::NumberWithUnit');

# call the postprocess for handling error messages and flags. 
# This needs to be called for the SignificantFigure and Units separately. 

sub cmp_postprocess {
	my ($self, $ansHash) = @_;
	warn $ansHash->{student_value}->type;
	warn ref $self->unit;
	$self->SUPER::cmp_postprocess($ansHash);
	# $self->unit->cmp_postprocess($ansHash);

	# Since the current $ansHash has the correct and student value as the NumberWithUnits type
	# pass in just the number (SignificantFigure) to the postprocess. 
	my $correct_value = $ansHash->{correct_value};
	my $student_value = $ansHash->{student_value};
	$ansHash->{correct_value} = $correct_value->number;
	$ansHash->{student_value} = $student_value->number;
	$self->SUPER::cmp_postprocess($ansHash);
	$ansHash->{correct_value} = $correct_value;
	$ansHash->{student_value} = $student_value;
}

package context::SignificantFiguresUnits;

sub Init {
	my $context = $main::context{SignificantFiguresUnits} = context::Units::extending('SignificantFigures');
	$context->{value}{NumberWithUnit}     = 'context::SignificantFiguresUnits::NumberWithUnit';
	$context->{value}{'Number-with-Unit'} = 'context::SignificantFiguresUnits::NumberWithUnit';
	$context                              = $main::context{LimitedSignificantFiguresUnits} = $context->copy;
	$context->{name}                      = 'LimitedSignificantFiguresUnits';
	$context->parens->undefine('|', '{', '[');
	$context->variables->remove('x');
	$context->operators->undefine('-', '+', '/', '//', ' /', '/ ', '!', '_', '.', 'U', '><');
	$context->flags->set(limitedSigFigs => 1);
}

1;

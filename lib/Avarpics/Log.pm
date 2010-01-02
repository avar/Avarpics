package Avarpics::Log;
use Moose;
use File::Slurp 'slurp';

has logdir => ( is => 'ro', required => 1 );
has logpre => ( is => 'ro', required => 1 );
has logext => ( is => 'ro', required => 1 );
has channel => ( is => 'ro', required => 1 );

sub files {
    my ($self) = @_;

    my $LOGDIR = $self->logdir;
    my $LOGPRE = $self->logpre;
    my $LOGEXT = $self->logext;

	my @files = reverse glob("$LOGDIR/*.$LOGEXT");

	foreach my $file (@files) {
		$file =~ s{\.$LOGEXT}{};
		$file =~ s{$LOGDIR/$LOGPRE}{};
	}

	@files;
}

sub on_date_slurp
{
    my ($self, $date) = @_;

    my $LOGDIR = $self->logdir;
    my $LOGPRE = $self->logpre;
    my $LOGEXT = $self->logext;

	my $file = "$LOGDIR/$LOGPRE$date.$LOGEXT";

    slurp($file);
}

__PACKAGE__->meta->make_immutable;

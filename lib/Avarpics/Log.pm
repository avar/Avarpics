package Avarpics::Log;
use Moose;
use File::Slurp 'slurp';

has logdir => ( is => 'ro', required => 1 );
has logpre => ( is => 'ro', required => 1 );
has logext => ( is => 'ro', required => 1 );
has channel => ( is => 'ro', required => 1 );

sub valid_day
{
    my ($self, $day) = @_;

    return unless $day =~ /^(\d\d\d\d-\d\d-\d\d)$/;
    for ($self->files) {
        return 1 if $day eq $_;
    }
    return;
}

sub files {
    my ($self) = @_;

    my $LOGDIR = $self->logdir;
    my $LOGPRE = $self->logpre;
    my $LOGEXT = $self->logext;

	my @files = reverse glob("$LOGDIR/*.$LOGEXT");

	foreach my $file (@files) {
        $file =~ s{^$LOGDIR/}{};
		$file =~ s{\.$LOGEXT}{};
        $file =~ s{^$LOGPRE}{};
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

package Avarpics::Log;
use Modern::Perl;
use File::Slurp 'slurp';
use WWW::Mechanize;

sub new
{
    my ($class, %conf) = @_;
    bless \%conf => $class;
}

sub files {
    my ($self) = @_;

    my $LOGDIR = $self->{logdir};
    my $LOGPRE = $self->{logpre};
    my $LOGEXT = $self->{logext};

	my @files = reverse glob("$LOGDIR/*.$LOGEXT");

	foreach my $file (@files) {
		$file =~ s{\.$LOGEXT}{};
		$file =~ s{$LOGDIR/$LOGPRE}{};
	}

	@files;
}

sub latest_file
{
    my ($self) = @_;

    (($self->files)[0]);
}

sub on_date_slurp
{
    my ($self, $date) = @_;

    my $LOGDIR = $self->{logdir};
    my $LOGPRE = $self->{logpre};
    my $LOGEXT = $self->{logext};

	my $file = "$LOGDIR/$LOGPRE$date.$LOGEXT";

    slurp($file);
}

1;

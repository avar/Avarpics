package Avarpics::Log;
use Moose;
use File::Slurp 'slurp';
use POSIX 'strftime';
use Date::Calc qw(Add_Delta_Days);
use WWW::Mechanize;

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

sub latest_day
{
    my ($self) = @_;

    ($self->files())[0];
}

sub day_exists
{
    my ($self, $day) = @_;
    my @files = $self->files;
    my %files;
    @files{@files} = ();

    exists $files{$day};
}

sub is_today
{
    my ($self, $day) = @_;

    # Don't show next links if it's today
    my $today = strftime("%Y-%m-%d", localtime);

    return $today eq $day;
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

sub data_for_day {
    my ($self, $date) = @_;

    my $text = $self->on_date_slurp( $date );

    my ($current_nick, %seen, @uris);

    # Need to define this outside loop as it has to persist from
    # a *chan URI (which is not kept) to the following ImageShack URI.
    my $comment;

    my $img_count = 0;
    my $vid_count = 0;

    foreach my $line (split /\n/, $text) {
        if ($line =~ /<(?:\@|\+| )(\w+)>/) {
            $current_nick = $1;
        }

        my $fileext = qr/\.(?:jpg|jpeg|gif|png|bmp)/i;

        if ($line =~ m{(http://[\S]+?$fileext)}) {
            my $uri = $1;

            if ($line =~ /\s+#\s+(.*)/) {
                $comment = $1;
            }

            if (!$seen{$uri} && $uri !~ /\dchan\./) {

                push @uris, {
                    'type'    => 'img',
                    'uri'     => $uri,
                    'who'     => $current_nick,
                    'comment' => $comment,
                };

                $img_count++;       
                undef $comment; 
            }

            $seen{$uri} = 1;
        } elsif ($line =~ m#youtube\.com/watch\?v=(\w{11})#) {
            my $id = $1;

            my ($vid_comment) = $line =~ /\s+#\s+(.*)/g;

            push @uris, {
                'type'    => 'vid',
                'id'      => $id,
                'who'     => $current_nick,
                'comment' => $vid_comment,
            };

            $vid_count++;
        } elsif ($line =~ m#(http://www.flickr.com/photos/\w+/\d{10}/)#) {
            my $flickr = $1;
            my ($flickr_id) = $flickr =~ m#(\d{10})#;

            my $mech = WWW::Mechanize->new;
            $mech->agent_alias('Windows IE 6');
            $mech->get($flickr);
            next unless $mech->success;

            $mech->content =~ m#<link rel="image_src" href="(http://farm\d.static.flickr.com/\d+/\d{10}_\w{10}_\w.jpg)" />#gs;
            my $uri = $1;
            next unless $uri;

            if (!$seen{$uri}) {

                push @uris, {
                    'type'      => 'img',
                    'uri'       => $uri,
                    'who'       => $current_nick,
                    'comment'   => $comment,
                    'flickr_id' => $flickr_id,
                };

                $img_count++;       
                undef $comment; 
            }

            $seen{$uri} = 1;
        }
    }

    my $options = {
        'date'      => $date,
        'uris'      => \@uris,
        'img_count' => $img_count,
        'vid_count' => $vid_count,
    };

    my $prev = $self->get_date_str($date, -1);
    my $next = $self->get_date_str($date,  1);

    $options->{'prev_day'} = $prev;
    $options->{'next_day'} = $next;

    %$options;
}

sub get_date_str
{
    my ($self, $date, $offset) = @_;

    my ($year, $month, $day) = $date =~ /(\d\d\d\d)-(\d\d)-(\d\d)/g;

    my ($pdy, $pdm, $pdd) = Add_Delta_Days($year, $month, $day, $offset);
    $pdm = sprintf("%02d", $pdm);
    $pdd = sprintf("%02d", $pdd);

    "$pdy-$pdm-$pdd";
}

__PACKAGE__->meta->make_immutable;

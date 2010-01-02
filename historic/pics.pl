#!/usr/bin/perl -T

use warnings;
use strict;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Date::Calc qw(Add_Delta_Days);
use File::Slurp qw(slurp);
use Template;
use WWW::Mechanize;

my $LOGDIR = '../logs';
my $LOGEXT = 'log';
my $LOGPRE = 'avar-';
my $CHANNEL = '#avar';

my $cgi = CGI->new;

my $log  = $cgi->param('log');
my $menu = $cgi->param('menu');

if ($menu) {
	menu();
} elsif ($log) {
	check_log($log);
} else {
	latest();
}

sub check_log {
	my $log = shift;

	if ($log =~ /^(\d\d\d\d-\d\d-\d\d)$/) {
		process($1);
	} else {
		bad();
	}
}

sub list_files {
	my @files = reverse glob("$LOGDIR/*.$LOGEXT");

	foreach my $file (@files) {
		$file =~ s{\.$LOGEXT}{};
		$file =~ s{$LOGDIR/$LOGPRE}{};
	}
	
	@files;
}

sub latest {
	my $latest = (list_files())[0];
	
	process($latest);
}

sub menu {
	print_header('#avar pic-o-matic');

	print "</head>\n<body>\n<h1>$CHANNEL pic-o-matic</h1>\n";

	my @files = list_files();
	my $total = scalar @files;
	
	print qq{<table id="days">\n};
	print qq{\t<tr>\n\t\t<td>};
	
	my $month;
	my $row_cells = 1;
	
	foreach my $file (list_files()) {
		my ($file_month) = $file =~ /\d{4}-(\d{2})-\d{2}/g;
		
		$month = $file_month unless $month;
		
		if ($file_month ne $month) {
			$month = $file_month;
		
			if ($row_cells == 6) {	
				print qq{\n\t</tr>\n\t<tr>\n};
				$row_cells = 1;
			} else {
				print qq{</td>\n\t\t<td>};
			}
		}

		print qq{<a href="?log=$file">$file</a><br />\n};
	}

	print qq{</td>\n\t</tr>\n</table>\n};

	print "</body>\n</html>";

	exit;
}

sub process {
	my $date = shift;
	
	my $file = "$LOGDIR/$LOGPRE$date.$LOGEXT";

	error('nonesuch') unless -f $file;
	error('problemo') unless -r $file;
	
	my $text = slurp($file);
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

	print_results({
		'date'      => $date,
		'uris'      => \@uris,
		'img_count' => $img_count,
		'vid_count' => $vid_count,
	});
}

sub print_results {
	my $options = shift;
	my $date = $options->{'date'};
	
	my $title = "Pics from $CHANNEL for $date";
	$options->{'title'} = $title;

	my ($year, $month, $day) = $date =~ /(\d\d\d\d)-(\d\d)-(\d\d)/g;

	my ($pdy, $pdm, $pdd) = Add_Delta_Days($year, $month, $day, -1);
	$pdm = sprintf("%02d", $pdm);
	$pdd = sprintf("%02d", $pdd);
	
	my ($ndy, $ndm, $ndd) = Add_Delta_Days($year, $month, $day, 1);
	$ndm = sprintf("%02d", $ndm);
	$ndd = sprintf("%02d", $ndd);
	
	$options->{'prev_day'} = join '-', ($pdy, $pdm, $pdd);
	$options->{'next_day'} = join '-', ($ndy, $ndm, $ndd); 
	
	print_header($title);

	Template->new->process(\*DATA, $options);
}

sub print_header {
	my $title = shift;
	
	print <<"END_HTML";
Content-Type: text/html; charset=UTF-8;

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>$title</title>
	<link rel="stylesheet" type="text/css" href="style.css" />
END_HTML

}

sub bad {
	print "Content-Type: image/jpeg\n";
	print "Location: http://lemonparty.org/lemonparty.jpg\n\n";
	exit;
}

sub error {
	print "Content-Type: text/plain\n\n";
	print shift();
	exit;
}

__END__
<script type="text/javascript">
function big(img) {
	img.style.width='600px';
}

function small(img) {
	img.style.width='425px';
}
</script>
</head>
<body>
<h1>[% title %]</h1>
<h2>[% IF img_count > 0 %][% img_count %] images[% IF vid_count > 0 %], [% END %][% END %][% IF vid_count > 0 %][% vid_count %] videos[% END %]</h2>
<div id="toc">

<a href="#pics" style="font-weight: bold">skip to pics &darr;</a> &nbsp; <a href="?log=[% prev_day %]">&larr; prev day</a> &nbsp; <a href="?log=[% next_day %]">next day &rarr;</a> &nbsp; <a href="?menu=1">list all days</a>
<ol>
[% anchor = 1 %]
[% FOREACH uri IN uris %]
	<li><a href="#[% anchor %]">[[% uri.type %]] [% uri.who %][% IF uri.comment %]: [% uri.comment %][% END %]</a></li>[% anchor = anchor + 1 %]
[% END %]
</ol>
</div>
<div id="pics">
[% anchor = 1 %]
[% FOREACH uri IN uris %]
	<div class="pic" id="[% anchor %]">[% anchor = anchor + 1 %]
	<span class="nick">&lt;[% uri.who %]&gt;</span> [% IF uri.comment %]<span class="comment">[% uri.comment %]</span>[% END %]

	[% IF (uri.type == 'img') %]
		[% IF (uri.flickr_id) %]
		<a href="http://flickr.com/photo.gne?id=[% uri.flickr_id %]"><img src="[% uri.uri %]" width="425" onmouseover="big(this)" onmouseout="small(this)"></a>
		[% ELSE %]
		<a href="[% uri.uri %]"><img src="[% uri.uri %]" width="425" onmouseover="big(this)" onmouseout="small(this)"></a>
		[% END %]
	[% ELSIF (uri.type == 'vid') %]
		[% vid_uri  = "http://www.youtube.com/v/" _ uri.id       %]
		[% link_uri = "http://www.youtube.com/watch?v=" _ uri.id %]
		<object width="425" height="344">
			<param name="movie" value="http://www.youtube.com/v/[% uri.id %]&hl=en&fs=1"></param>
			<param name="allowFullScreen" value="true"></param>
			<embed src="[% vid_uri %]&hl=en&fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344">
			</embed>
		</object>
		<div class="vid_uri">
		<a href="[% link_uri %]">[% link_uri %]</a>
		</div>
		
	[% END %]
	</div>
[% END %]
<p>
<a href="?log=[% prev_day %]">&larr; prev day</a> &nbsp; <a href="?log=[% next_day %]">next day &rarr;</a> &nbsp; <a href="?menu=1">list all days</a>
</p>
</div>
</body>
</html>
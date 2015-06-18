use strict;
#use warnings;
use LWP::UserAgent;
use WWW::Mechanize;

my %uniqLinks;
my $counter;
my $filename = "links.txt";
open(my $fh, '>', $filename);

sub mysub{
	my $base_url=$_[0];
	my $mech = WWW::Mechanize->new(autocheck => 0);
	$mech->get( $base_url );
	my @links = $mech->links();
	for my $link ( @links ) {
	    if (($link->url =~ /$base_url/) && !($uniqLinks{$link->url}) && !($link->url =~ /css|php|jpg|pdf|JPG|xml|\?/) && length($link->url)>27) {
	    	$uniqLinks{$link->url} = 1;
	    	$counter++;
	    	print $counter," ",$link->url,"\n";
	    	print $fh $link->url,"\n";
#	    	sleep(1);
	    	mysub($link->url);
	    }
	}
}

mysub("https://<sitename>/");
print $counter;
close $fh;


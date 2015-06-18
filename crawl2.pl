#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use WWW::Mechanize;

my %uniqLinks;
my $pageCount;
my $imageCount;

my $linkfile = "links.txt";
open(my $lfh, '>', $linkfile);
my $imagefile = "images.txt";
open(my $ifh, '>', $imagefile);

sub mysub{
    my $base_url=$_[0];
    my $mech = WWW::Mechanize->new(autocheck => 0);
    $mech->get( $base_url );
    my @links = $mech->find_all_links();
    my @images = $mech->find_all_images();
    
    for my $link ( @images ) {
        if (($link->url =~ /$base_url/) && !($uniqLinks{$link->url}) && length($link->url)>27) {
            $uniqLinks{$link->url} = 1;
            $imageCount++;
            my $imageLink = $link->url;
            $imageLink =~ s/\/scripts\/timthumb.php\?src=//;
            $imageLink =~ s/&.*//;
            print $imageLink,"\n";
            print $ifh $imageLink,"\n";
            #sleep(1);
           # mysub($link->url);
        }
    }
    for my $link ( @links ) {
        if (($link->url =~ /$base_url/) && !($uniqLinks{$link->url}) && !(lc $link->url =~ /png|css|jpg|JPG|xml|\?/)) {
            $uniqLinks{$link->url} = 1;
            $pageCount++;
            print $pageCount," ",$link->url,"\n";
            print $lfh $link->url,"\n";
            sleep(1);
            mysub($link->url);
        }
#		elsif (($link->url =~ /$base_url/) && !($uniqLinks{$link->url}) && (lc $link->url =~ /\.png|\.jpg|\.pdf/) && length($link->url)>27){
#		    $uniqLinks{$link->url} = 1;
#	            $imageCount++;
#	            print $imageCount," ",$link->url,"\n";
#	            print $ifh $link->url,"\n";
#		}
    }
    
}

mysub("https://<sitename>");
print $lfh "Pages: ".$pageCount."\n";
print $ifh "Images: ".$imageCount."\n";
print "Pages: ".$pageCount.". Images: ".$imageCount."\n";
close $lfh;
close $ifh;

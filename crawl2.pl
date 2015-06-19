#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use WWW::Mechanize;
$DB::deep = 500; 

my %uniqLinks;
my $pageCount;
my $imageCount;
#need to escape periods and forward slashes in given url for comparison purposes later on
my $home_url = $ARGV[0];
$home_url =~ s/\./\\./g;
$home_url =~ s/\//\\\//g;

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
    
    #first grab all the image links on the page
    #to make links more readable, scrape out wordpresses timthumb reference
    #increase image count, write to stdout, write to imagefile
    for my $link ( @images ) {
        if (($link->url =~ /$home_url/) && !($uniqLinks{$link->url}) && length($link->url)>27) {
            $uniqLinks{$link->url} = 1;
            $imageCount++;
            my $imageLink = $link->url;
            $imageLink =~ s/\/scripts\/timthumb.php\?src=//;
            $imageLink =~ s/&.*//;
            print $imageLink,"\n";
            print $ifh $imageLink,"\n";
        }
    }
    #grab all links on page
    #disregard images
    #increase image counter
    #write to link file
    for my $link ( @links ) {
        if (($link->url =~ /$home_url/) && !($uniqLinks{$link->url}) && !(lc $link->url =~ /\/feed\/|png|css|jpg|JPG|xml|\?/)) {
            $uniqLinks{$link->url} = 1;
            $pageCount++;
            print $pageCount," ",$link->url,"\n";
            print $lfh $link->url,"\n";
            sleep(1); #try to be nice to webserver
            mysub($link->url); #recursively look at links on current page.
        }
    }
}


mysub($ARGV[0]);
print $lfh "Pages: ".$pageCount."\n";
print $ifh "Images: ".$imageCount."\n";
print "Pages: ".$pageCount.". Images: ".$imageCount."\n";
close $lfh;
close $ifh;

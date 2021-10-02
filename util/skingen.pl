#!/usr/bin/perl
use strict;
use warnings;
use Image::Size;
use Cwd 'abs_path';

################################################################################
# CSS "Skin" generator for 333networks web interfaces
#
# Every skin is built in the following way. The SKIN AUTHOR needs to make a
# config file at $ROOT/s/style/SKINNAME/conf
# Here, SKINNAME is a lowercase folder and conf a plaintext file. In this folder
# you can opt to place textures, logos and other pictures used in your skin.
# 
# For more information, see the README.md file of this repository.
#
# To compile a skin, run the command "./skingen.pl SKINNAME" where skinname is
# the lowercase folder name of your skin. The output is a style.css file in your
# folder. This style name can now be used in your webinterface config file under
# the "style => " option.
#
################################################################################

our($ROOT, %S);
BEGIN { ($ROOT = abs_path $0) =~ s{/util/skingen\.pl$}{}; }
use lib "$ROOT/lib";
use SkinFile;

# read styles to be compiled from commandline
if (scalar @ARGV) 
{
    # for every style name/folder provided
    for my $conf (@ARGV) 
    {
        print "Parsing $conf\n";
        writeskin($conf);
    }
}
else 
{
    # minimalistic help command
    print "Use: ./skingen.pl themename\n";
    print "\t themename is a folder like /s/style/themename\n";
    print "\t and contains a conf file with color codes. See\n";
    print "\t also comments in this script for more info.\n";
}

# args: theme name
sub writeskin 
{
    my $name = shift;
    my $skin = SkinFile->new("$ROOT/s/style", $name);
    my %o = map +($_ => $skin->get($_)), $skin->get;

    # body background color / image 
    my @bg = split ' ', $o{bodybg};
    if (substr($bg[0], 0, 1) eq '#') 
    {
        # col + img?
        if ($bg[1] && $bg[1] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
        {
            $o{_bodybg} .= "background: $bg[0] url(/style/$name/$bg[1]) repeat center top fixed;";
        }
        else 
        {
            $o{_bodybg} = "background: $bg[0];";
        }
    } # only img
    elsif ($bg[0] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
    {
        $o{_bodybg} = "background: url(/style/$name/$bg[0]) repeat center top fixed;";
    }
    
    # box background color / image
    @bg = split ' ', $o{boxbg1};
    
    if (substr($bg[0], 0, 1) eq '#') 
    {
        # col + img?
        if ($bg[1] && $bg[1] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
        {
            $o{_boxbg1} .= "background: $bg[0] url(/style/$name/$bg[1]) repeat center top;";
        }
        else 
        {
            $o{_boxbg1} = "background: $bg[0];";
        }
    } # only img
    elsif ($bg[0] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
    {
        $o{_boxbg1} = "background: url(/style/$name/$bg[0]) repeat center top;";
    }
    
    # box background color / image boxtype 2
    @bg = split ' ', $o{boxbg2};
    if (substr($bg[0], 0, 1) eq '#') 
    {
        # col + img?
        if ($bg[1] && $bg[1] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
        {
            $o{_boxbg2} .= "background: $bg[0] url(/style/$name/$bg[1]) repeat center top;";
        }
        else 
        {
            $o{_boxbg2} = "background: $bg[0];";
        }
    } # only img
    elsif ($bg[0] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
    {
        $o{_boxbg2} = "background: url(/style/$name/$bg[0]) repeat center top;";
    }
    
    # box background color / image boxtype 3
    @bg = split ' ', $o{boxbg3};
    
    if (substr($bg[0], 0, 1) eq '#') 
    {
        # col + img?
        if ($bg[1] && $bg[1] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
        {
            $o{_boxbg3} .= "background: $bg[0] url(/style/$name/$bg[1]) repeat center top;";
        }
        else 
        {
            $o{_boxbg3} = "background: $bg[0];";
        }
    } # only img
    elsif ($bg[0] =~ m/^\w+\.(gif|jpeg|jpg|png)$/i) 
    {
        $o{_boxbg3} = "background: url(/style/$name/$bg[0]) repeat center top;";
    }
    
    # site logo (overlay on background)
    $o{_bglogo} = "";
    if (-e "$ROOT/s/style/$name/$o{bglogo}") 
    {
        # get height
        my ($w, $h) = imgsize("$ROOT/s/style/$name/$o{bglogo}") or die $!;
        $o{_bglogo} = "background: url(/style/$name/$o{bglogo}) no-repeat center 10px fixed;";
        
        # padding compensates for div.mainbox { margin }
        $o{_bgpadd} = "padding-top: " . int(500/$w*$h-5) . "px;";
    }
    
    # png filter for symbols
    $o{_png_filter} = "";
    if (length($o{pngfilter} // "") > 1)
    {
        # symbol picture is white. filter assumes picture is black. force symbol to black first.
        $o{_png_filter} = "filter: brightness(0) saturate(100%) $o{pngfilter};";
    }
    
    # write the CSS
    open my $CSS, '<', "$ROOT/data/style.css" or die "$ROOT/util/skingen/style.css $!";
    my $css = join '', <$CSS>;
    close $CSS;
    $css =~ s/\$$_\$/$o{$_}/g for (keys %o);

    my $f = "$ROOT/s/style/$name/style.css";
    open my $SKIN, '>', "$f~" or die $!;
    print $SKIN $css;
    close $SKIN;
    rename "$f~", $f;
}

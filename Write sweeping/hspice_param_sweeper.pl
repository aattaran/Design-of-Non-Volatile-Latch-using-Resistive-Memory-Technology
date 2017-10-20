#!/usr/bin/perl
use 5.000000;
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

##############
# Change Log #
##############
# 1.00 Myles Prather
#   Initial version.
# 1.01 Myles Prather
#   Updated the help message to reflect the required "," character between
#   listed parameter values.

my $g_version = '1.08';
my $g_current_maintainer = 'Myles Prather, Myles.Prather@Synopsys.com';

#Getopt::Long::Configure("pass_through");
my $version = 0;
my $help = 0;
my $alter = 0;
my $data_set_name= '';
my $infile= 'sweeper_params';

GetOptions (
  'version|v' => \$version,
  'help|h' => \$help,
  'alter|a' => \$alter,
  'dsn|data-set-name=s' => \$data_set_name,
  'i|input-file=s' => \$infile,
);

if ($help) {
  pod2usage({ -exitval => 0, -verbose => 2, -output => \*STDOUT });
}

if ($version) {
  print "hspice_param_sweeper\n";
  print "Version            : $g_version\n";
  print "Current Maintainer : $g_current_maintainer\n";
  exit 0;
} 

$data_set_name ne ''  or $data_set_name = $infile;
$data_set_name =~ s/\./_/g;

# Read the input file and store everything into $ra_data
open(INFILE, $infile) or die "Cannot not read input file '$infile'.\n";
my $ra_data = [];
my $line_num = 1;
while(my $line = <INFILE>) {
  #print $line;
  if ($line =~ s/^\s*(\w+)\s*://) {
    push(@{$ra_data}, { symbol => $1, values => [] });
    while ($line =~ s/^\s*([+-]?\.?[0-9]+(\.[0-9]+)?(e[-+0-9][0-9]*)?)//) {
      push(@{$ra_data->[-1]->{values}}, $1);
      if ($line !~ s/^\s*,// && $line !~ s/^\s*$//) {
        die "Syntax error in '$infile', line number '$line_num'. Expected ',' after '$ra_data->[-1]->{values}->[-1]', none found.\n";
      }
    }

    # For data table creation, the temperature parameter 'temp' must always be first in the list.
    if ($ra_data->[-1]->{symbol} =~ /^temp$/i) {
      unshift(@{$ra_data}, pop(@{$ra_data}));
    }
  }
  ++$line_num;
}
close INFILE;

#print Dumper($ra_data); die;

my $overflow = 0;
my $alter_text = '';
my $data_table_text = ".DATA $data_set_name ";

# This special counter array is where the permutation magic happens.
my $ra_counter = [];
for (my $i = 0;  $i <= $#{$ra_data}; ++$i) {
  # Create the multi-base counter.
  push(@{$ra_counter}, { value => 0, base => $#{$ra_data->[$i]->{values}} });

  # Create the list of symbols that go on the .data line.
  if ($i > 0) { $data_table_text .= ' '};
  $data_table_text .= $ra_data->[$i]->{symbol};
}

$data_table_text .= "\n";

# Count through all the posbile values of the multi-base counter
until ($overflow) {
  my ($alter, $data_table_corner);
  ($alter, $data_table_corner) = gen_corner($ra_data, $ra_counter);
  $alter_text .= $alter;
  $data_table_text .= $data_table_corner;
  $overflow = increment_counter($ra_counter);
  #print Dumper($ra_counter);
}

$data_table_text .= ".ENDDATA\n";

if ($alter) {
  print $alter_text;
} else {
  print $data_table_text;
}

exit 0;

sub increment_counter {
  my $ra_counter = shift;

  my $i = 0;
  my $overflow = 0;

  until ($overflow) {
    ++$ra_counter->[$i]->{value};
    if ($ra_counter->[$i]->{value} <= $ra_counter->[$i]->{base}) {
      last;
    }
    $ra_counter->[$i]->{value} = 0;
    ++$i;
    if ($i > $#{$ra_counter}) {
      $overflow = 1;
    }
  }
  return $overflow;
}

sub gen_corner {
  my $ra_data = shift;
  my $ra_counter = shift;

  #print Dumper($ra_data);
  #print Dumper($ra_counter);
  my $alter = ".ALTER\n";
  my $data_table_row = '';
  my $i = 0;

  foreach my $rh_symbol (@{$ra_data}) {
    if ($i > 0) { $data_table_text .= ' '};
    my $symbol_name = $rh_symbol->{symbol};
    my $ra_symbol_values = $rh_symbol->{values};
    if ($symbol_name =~ /^temp$/i) {
      $alter .= ".TEMP $ra_symbol_values->[$ra_counter->[$i]->{value}]\n";
    } else {
      $alter .= ".PARAM $symbol_name=$ra_symbol_values->[$ra_counter->[$i]->{value}]\n";
    }

    $data_table_text .= $ra_symbol_values->[$ra_counter->[$i]->{value}];

    ++$i;
  }

  $data_table_row .= "\n";

  return ($alter, $data_table_row);
}

sub get_usage {
  "Usage: $0 [ options ]\n" .
  "  Options:\n" .
  "    -h|--help       Display a help message.\n" .
  "    -v|--version    Display the script version number.\n" .
  "    -a|--alter      Generate .ALTER's instead of the default .DATA table\n" .
  "    --data-set-name The name used after .DATA (see HSPICE manual)\n" .
  "";
}

__END__

=head1 NAME

hspice_param_sweeper - Reads in parameter value lists and permutates them into .DATA or .ALTER blocks.

=head1 SYNOPSIS

hspice_param_sweeper [-v] [-h] [-a] [-dsn B<name>] [-i B<input-file>]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Displays a help message and exits.

=item B<-v, --version>

Displays a version message and exits.

=item B<-a, --alter>

The default operation will generate a .DATA block. If this option is
specified, a list of .ALTER's will be created instead.

=item B<-dsn, --data-set-name <name>>

An HSPICE .DATA block requires a name. The default name will be the
name of the input file. You can use this option to change the default
behaviour.

=item B<-i, --input-file <filename>>

The default input file name is 'sweeper_params'. If you want to use a
different input file name, specify it here. Note that this filename
will become the default data set name.

=back

=head1 DESCRIPTION

The input file ('sweeper_params' by default) should be created using this format.

  <param_name_1>: <value>, [ <value>, ... ]
  ...
  <param_name_n>: <value>, [ <value>, ... ]

The special param name 'temp' may be used to sweep temperatures.

Example. Place the following in a file named 'sweeper_params' and run 'hspice_param_sweeper'.

  vddr: 1.2, 1.0, 0.8
  vssr: 0.0
  temp: 0, 100

This input will create this .DATA table.

  .DATA corners temp vddr vssr
  0 1.2 0.0
  100 1.2 0.0
  0 1.0 0.0
  100 1.0 0.0
  0 0.8 0.0
  100 0.8 0.0
  .ENDDATA

Note that all options to hspice_param_sweeper are optional. It may be run using all defaults
by simply invoking the script.

=head1 KNOWN LIMITATIONS

1) The script does minimal error checking. User beware! The robustness will probably
be enhanced in future releases.

Please report bugs to myles.prather@synopsys.com.

=cut

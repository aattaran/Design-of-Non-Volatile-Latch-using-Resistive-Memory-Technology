#!/usr/local/bin/perl
##############################################################################
# Programed by Hamid Mahmoodi
# Nano-electronics & Computing Research Lab
# Nov. 15, 2015
# Measurement extraction from Hspice output file
##############################################################################
use Cwd;

$i = 0;
$b = "mont_Write2.mt0";
$dir = getcwd;

  while(-f "$dir/$b"){
  
    $hspout = "$b";
    print "\n\nAlter #$i\n\n";    
    $i = $i+1; 
    $b = "mont_Write.mt$i"; 
    $fail_count=0;
    $line=5;
    ################################################################
    # Main loop begin
    ################################################################
        open(INHSPOUT,"$hspout") || die "couldn't open file [$hspout]\n";
       
        $skip = ($inpline = <INHSPOUT>);
        $skip = ($inpline = <INHSPOUT>);
        $skip = ($inpline = <INHSPOUT>);
        $skip = ($inpline = <INHSPOUT>);
        @tmpd = split(/\s+/,$inpline);
        $idx=0;    
        foreach $item (@tmpd) {
    
    	         if ($item eq "ntrh" )   { $ntrh_index = $idx; };
               if ($item eq "ntdl" )   { $ntdl_index = $idx; };
               if ($item eq "ntrl1" )   { $ntrl1_index = $idx; };
               if ($item eq "ntdh1" )   { $ntdh1_index = $idx; }; 
               if ($item eq "ntdh2" )   { $ntdh2_index = $idx; }; 	
               if ($item eq "ntrl2" )   { $ntrl2_index = $idx; };
               $idx = $idx + 1;
    
               }#foreach
    
        while ($inpline = <INHSPOUT>) { 
               @tmpd = split(/\s+/,$inpline);
    
    	         $ntrh  =   @tmpd[$ntrh_index];
               $ntdl =   @tmpd[$ntdl_index];
               $ntrl1=   @tmpd[$ntrl1_index];
               $ntdh1 =   @tmpd[$ntdh1_index];	
               $ntdh2 =   @tmpd[$ntdh2_index];	
               $ntrl2=   @tmpd[$ntrl2_index];    
      
           if (($ntrh< 2.9) || ($ntrl1 >.3) || ($ntdl > .3) || ($ntdh1 < 2.9) || ($ntdh2 < 2.9) || ($ntrl2 >.3)) {
               
               $fail_count = $fail_count +1;
               print "Failure at line number $line : ntrh =  $ntrh, ntrl = $ntrl, ntdl1 = $ntdl1, ntdh1 = $ntdh1, ntdh2 = $ntdh2, ntdl2 = $ntdl2 \n";
           } #if
    
              $line = $line +1;
    
        } #while
        $total_sim = $line -5;
        $Percentage_Failure = ((1 - ($fail_count/$total_sim))*100);
    
        print " \nTotal Fail: $fail_count \n Total Sims: $total_sim cases \n Success Rate: $Percentage_Failure% \n";
    
        close(INHSPOUT);}
  
  exit;        
        
        
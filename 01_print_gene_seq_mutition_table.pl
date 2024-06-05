#!/usr/bin/perl -w
=head
	this  script is used for get the mutated genes;
		perl  get.gene.seq.mutation.pl  -in inputfile -out outfile
		
	input format:
	>domecattle
	---------------------------MQASASNSSGDTQCPVNFSEAADSVLSGLQDDFLWPMLVVEFLVALAGNSLALYRFCSREQHLWPPAMIFSAQLAVSDLLYALTLPPLAAYIYPPKHWRYGEAACRLERFLFTCNLLGSVIFITCISLNRYMGIVHPFFTHSQLRPKHAWAVSAAGWVLAVLLAAPTLSFSHLSESQRPGQCSVANLGACTKCLGTAGDSQLEAYRVYSLALATLGCGLPLLLTLAAYGALGRAVQHSHGMTAANKLQVTVLVASGVALYASSYVPYYITAVLNVYARLRWLALCPGFTSEAAAKKALAQRTYLAHQVTRGLVPLAICIHPLLYMAVVPSLDCCHQCCGQGQTPKSTTCSSQALPLNVTATPQTSGLQSHELSP
	>Americabison
	MGGASGLCLRREHAAQATVQLQTQRQAMQASASNSSGDTQCPVNFSQAADSVLSGLQDGFLWPMLVVEFLVALAGNSLALYRFCSREQHPWPPAMIFSAQLAVSDLLYALTLPPLAAYIYPPKHWRYGEAACRLERFLFTCNLLGSVIFITCISLNRYMGIVHPFFTHSQLRPKHAWAVSAAGWVLAVLLAAPTLSFSHLSKSQRPGQCSVANLGACTKCLGTAGDSQLEAYRVYSLALVTLGCGLPLLLTLAAYGALGRAVQHSHGMTAANKLQVTVLVASGVALYASSYVPYYITAVLNVYARLRWLALCPGFTSEAAAEKALDQRTYLAHQVTRGLVPLAICIHPLLYMAVVPSLDCCHQCCGQGQTPKSTTCSSQALPLNVTATPQTSGLQSHELSP
	>Europenbison
	---------------------------MQASASNSS-DTQCPVNFSEAADSVLSGLQDGFLWPMLVVEFLVALAGNSLALYRFCSREQHPWPPAMIFSAQLAVSDLLYALTLPPLAAYIYPPKHWRYGEAACRLERFLFTCNLLGSVIFITCISLNRYMGIVHPFFTHSQLRPKHAWAVSAAGWVLAVLLAAPTLSFSHLSKSQRPGQCSVANLGACTKCLGTAGDSQLEAYRVYSLALVTLGCGLPLLLTLAAYGALGRAVLHSHGMTAANKLQVTVLVASGVALYASSYVPYYITAMLNVYARLRWLALCPGFTSEAAAEKALDQRTYLAHQVTRGLVPLAICIHPLLYMAVVPSLDCCHQCCGQGQTPKSTTCSSQALPLNVTATPQTSGLQSHELSP
=cut

use warnings;
#use strict;
use Getopt::Long;
use Cwd;
use File::Basename;

my ($in,$help,$out);
GetOptions(
        "in:s"=>\$in,
        "out:s"=>\$out,
        "help"=>\$help          #specify the help information
);

print "$in\n";
my @file=glob "$in";
print "@file\n";
if(scalar(@file)==0){die "Files are not exists!\n";}

my @species;
my %hash_mutation;
my %hash_gene;
my %hash_length;
my %hash_count;
for(my $i=0;$i<@file;$i++){
	open IN, "$file[$i]"||die "$file[$i] can not open !";
	my @suffixlist=qw(.pep.best.fas );
	my ($filename,$path,$suffix)=fileparse($file[$i],@suffixlist);
	#print"$filename\t$path\t$suffix\n\n";
	
	$/=">";	<IN>;
	my %hash_seq;
	my $length;
	while(my $line=<IN>){
		chomp($line);
		my @inf=split(/\n/,$line);
		my $name=shift @inf;			push @{$hash_gene{$filename}}, $name;	
		
		my @inf1=split(/\|/,$name); 	$species=$inf1[0];              push @species, $species;
		my $seq=join "", @inf;          $length=length($seq);			$hash_length{$filename}=$length;
		my @base=split(//,$seq);
		for(my $j=0;$j<@base;$j++){	push  @{$hash_seq{$species}{$j}},$base[$j];}
	}
	close IN;
	#print "$file[$i]\t$length\n";
	
	my %tmp_hash1;	@species=grep {++$tmp_hash1{$_}<2} @species;	@species=sort @species;
	for(my $a=0;$a<$length;$a++){
		my @new_base;
		for(my $b=0;$b<@species;$b++){
			if(!exists $hash_seq{$species[$b]}{$a}){push @{$hash_seq{$species[$b]}{$a}}, "NA";}
			my @array=@{$hash_seq{$species[$b]}{$a}};
			#print"$species[$b]\t@array\n";
			foreach my $tmp_array(@array){push @new_base,$tmp_array;}
		}
		
		my %tmp_hash2;	@new_base=grep {++$tmp_hash2{$_}<2} @new_base;	@new_base=sort @new_base;		
		next if(scalar(@new_base)==1);##remove all "-"  or same base at the same site
	
		for(my $b=0;$b<@species;$b++){
			my @array=@{$hash_seq{$species[$b]}{$a}};
			my $tmp_array=join " ", @array;
			$hash_mutation{$filename}{$a}{$species[$b]}=$tmp_array;
			#print "$filename\t$a\t$species[$b]\t$tmp_array\n";
		}
		
		if(!exists $hash_count{$filename}){$hash_count{$filename}=0;}
		$hash_count{$filename}++;
	}	
}


open OUT, ">$out "||die "$out can not open !";
my %tmp_hash3;	@species=grep {++$tmp_hash3{$_}<2} @species;	@species=sort @species;
print OUT "#File\tGenename\tLength\tposition";
for(my $i=0;$i<@species;$i++){ print OUT "\t$species[$i]";}
print OUT "\n";

foreach my $tmp1(sort keys %hash_mutation){
	if(!exists $hash_gene{$tmp1}){ print  "$tmp1\n";}
	my @tmparray=@{$hash_gene{$tmp1}};
	my $genename=join ";", @tmparray;	
	
	foreach my $tmp2(sort {$a<=>$b} keys %{$hash_mutation{$tmp1}}){
		my $location=$tmp2+1;
		my $lengthcov=$hash_count{$tmp1}/$hash_length{$tmp1};
		
		#if($lengthcov >=  0.60){print "*****$hash_count{$tmp1}\t$tmp1\t$genename\t$hash_length{$tmp1}\t$location\n";  next; }
	
		print OUT "$tmp1\t$genename\t$hash_length{$tmp1}\t$location";
		foreach my $tmp3(sort @species){
			if(!exists $hash_mutation{$tmp1}{$tmp2}{$tmp3}){$hash_mutation{$tmp1}{$tmp2}{$tmp3}="NA";}
			print OUT "\t$hash_mutation{$tmp1}{$tmp2}{$tmp3}";
		}
		print OUT "\n";
	}
}
close OUT;

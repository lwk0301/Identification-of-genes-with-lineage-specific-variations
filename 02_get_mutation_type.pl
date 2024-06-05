use strict;
#use warnings;
my (%hash_out, %hash_adv,%hash_in, %hash_in_pos,%hash_out_pos, %hash_adv_pos, $num, @info_out, @info_in,@info_adv, @uniq_times, $num_check);
 
#USAGE:perl 02_get_mutation_type.pl list.bed all_mutition.list

my$in=$ARGV[0];
open FA,$in;
$/="\n";
while (<FA>) {
	chomp;
	my @info1 = split /\s+/,$_;
	if ($info1[1] eq "ingroup1") {
		$hash_out{$info1[0]}=1;
	}elsif ($info1[1] eq "ingroup2") {
		$hash_in{$info1[0]}=2;
	}elsif($info1[1] eq "advolution"){
		$hash_adv{$info1[0]}=3;
	}else{}
}

my$head="";
my @info;
open FB, $ARGV[1];
$/="\n";
open O1,">ingroup_deletion.list";
open O2,">ingroup_insertion.list";
open O3,">ingroup_fixed.list";

while (<FB>) {
	chomp;
	if ($_ =~ m/^#.*/) {
		#$head=$_;
		#print"$_\n";
		@info = split /\s+/, $_;
		my $num = @info;

		for (my $n=4; $n<$num; $n++) {
			if (exists $hash_out{$info[$n]}) {
				$hash_out_pos{$n}=1;
			}elsif (exists $hash_adv{$info[$n]}) {
				$hash_adv_pos{$n}=1;
			}elsif(exists $hash_in{$info[$n]}){
				$hash_in_pos{$n}=1;
			}
		}
		my@tmp;
		foreach my $key1(sort {$a<=>$b}keys%hash_out_pos){push (@tmp,$info[$key1]);}
		foreach my $key2(sort {$a<=>$b}keys%hash_adv_pos){push (@tmp,$info[$key2]);}
		foreach my $key3(sort {$a<=>$b}keys%hash_in_pos){push (@tmp,$info[$key3]);}
		
		$head=join"\t",($info[0],$info[1],$info[2],$info[3],@tmp);
		print O1 "$head\n";
		print O2 "$head\n";
		print O3 "$head\n";
		
	}else{
		
		@info = split /\s+/, $_;
		my@tmp;
		foreach my $key1(sort {$a<=>$b}keys%hash_out_pos){push (@tmp,$info[$key1]);}
		foreach my $key2(sort {$a<=>$b}keys%hash_adv_pos){push (@tmp,$info[$key2]);}
		foreach my $key3(sort {$a<=>$b}keys%hash_in_pos){push (@tmp,$info[$key3]);}
		my $str=join"\t",($info[0],$info[1],$info[2],$info[3],@tmp);
		#print"$str\n";
		
		my $num = @info;
		my $out = "";
		my $adv = "";
		my $in = "";
		my @info_out = ();
		my @info_adv = ();
		my @info_in = ();
		my%out_base;my%in_base;my%adv_base;
		
		for (my $n=4; $n<$num; $n++) {
			if (exists $hash_out_pos{$n}) {
				push @info_out, $info[$n];
				$out_base{$info[$n]}++;
			}elsif (exists $hash_adv_pos{$n}) {
				push @info_adv, $info[$n];
				$adv_base{$info[$n]}++;
			}elsif(exists $hash_in_pos{$n}){
				push @info_in, $info[$n];
				$in_base{$info[$n]}++;
			}
		}
		my $num_out = @info_out;
		my $num_adv = @info_adv;
		my $num_in = @info_in;
		#print"$num_in\t$num_out\t$num_adv\n";

		my %count;
		my @uniq_in_base = grep { ++$count{ $_ } < 2; } @info_in;
		my%count2;
		my @uniq_out_base = grep { ++$count2{ $_ } < 2; } @info_out;
		my%count3;
		my @uniq_adv_base = grep { ++$count3{ $_ } < 2; } @info_adv;
		my $num_in_uniq = @uniq_in_base;my $num_out_uniq = @uniq_out_base;my $num_adv_uniq = @uniq_adv_base;
		
		if ($num_in_uniq == 1 && $uniq_in_base[0] eq "-" ) {
			if($num_out_uniq == 1 && $uniq_out_base[0] eq "-"){
				#pass
			}elsif($num_out_uniq == 1 && $uniq_out_base[0] ne "-"){
				##deletion in ingroup
				print O1 "$str\n";
			}else{
			}
			
		}elsif($num_in_uniq == 1 && $uniq_in_base[0] ne "-"){
			if($num_out_uniq == 1 && $uniq_out_base[0] eq "-"){
				#uniq insertion in ingroup
				print O2 "$str\n";
			}elsif($num_out_uniq == 1 && $uniq_out_base[0] ne "-" && ($uniq_out_base[0] ne $uniq_in_base[0])){
				##uniq fixed base in ingroup
				print O3 "$str\n";
			}else{
			}
			
		}

		# $num_check = 0;
		# foreach my $b (@info_adv) {
			# if (($b ne "-") && ($out ne "")) {
				# $num_check = $num_check + 1;
			# }else{
			# }
		# }
		# if ($num_check >= 12) {
			# print "$_\n";
		# }
		# $num_check = 0;
	}
}

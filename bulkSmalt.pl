#!/usr/bin/env perl

# Shashwat Deepali Nagar, 2017
# Jordan Lab, Georgia Tech

# Script for running SMALT for all the reads in a directory.

my $usage = "Usage:\n $0 <Reference genome> <Output directory> <Inpur directory with reads> \n\n";

die $usage if @ARGV < 3;

my $reference = $ARGV[0];
my $outDir = $ARGV[1];
my $inDir = $ARGV[2];

my ($read1, $read2);
chomp(my @fileList = `ls $inDir | awk '{if(\$0 !~ /README/ && \$0 !~ /kmer/ && \$0 !~ /trim_galore/){print;}}'`);

`smalt index refIndex $reference`;

for (my $i = 0; $i < scalar @fileList; $i++) {
    $read1 = $fileList[$i];
    $read1 =~ /(OB\d\d\d\d)/;
    $i += 1;
    $read2 = $fileList[$i];
    `mkdir $outDir/$1`;
    `smalt map -n 4 -o $1.sam refIndex $inDir/$read1 $inDir/$read2`;
    `samtools view -bS $1.sam > $1.bam`;
    `samtools sort $1.bam -o $1.sorted.bam`;
    `samtools index $1.sorted.bam`;
    `samtools mpileup -f $reference -gu $1.sorted.bam | bcftools call -c --output-type b --output $1.final_raw.bcf`;
    `bcftools view -O v $1.final_raw.bcf | vcfutils.pl vcf2fq > $1.fastq`;
    `seqret -sequence $1.fastq -outseq $outDir/$1/$1.fasta`;

}

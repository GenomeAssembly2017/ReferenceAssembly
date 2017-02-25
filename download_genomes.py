##
# @file download_genomes.py
# @brief Script for downloading serovar Heidelberg genomes. 
# @author Ankit Srivastava <asrivast@gatech.edu>
# @version 1.0
# @date 2017-02-25
# 
# This script can be used for downloading all the genomes
# from RefSeq database for Serovar enterica subsp. enterica
# serovar Heidelberg, using the FTP links provided in a CSV
# file. This downloads the genomes in the current directory.
# 
# Usage:
# python download_genomes.py <csv file> 

import csv
import os
import sys
import ftplib 

if len(sys.argv) < 2:
    raise RuntimeError, 'CSV file containing RefSeq FTP addresses for all the genomes is required as an argument.'

with open(sys.argv[1], 'rb') as f:
    allGenomes = csv.DictReader(f)
    for genome in allGenomes:
        if genome['#Organism/Name'].startswith('Salmonella enterica subsp. enterica serovar Heidelberg'):
            ftpAddress = genome['RefSeq FTP']
            ftpAddress = ftpAddress.replace('ftp://', '')
            ncbi, assembly = ftpAddress.split('/', 1)
            ftp = ftplib.FTP(ncbi)
            ftp.login()
            ftp.cwd(assembly)
            outDir = ftpAddress.rsplit('/', 1)[-1]
            if not os.path.exists(outDir):
                os.makedirs(outDir)
            for fileName in ftp.nlst():
                with open(os.path.join(outDir, fileName), 'wb') as f:
                    ftp.retrbinary('RETR ' + fileName, f.write)
            ftp.quit()

nobackup="/proj/b2012036/nobackup/mutations"
somac="/proj/b2012036/SOMAC"
dreamdata="/proj/b2012036/DREAM/Synthetic/Data"
mkdir -p $nobackup/dataset2_splitchr
mkdir -p $nobackup/dataset2_script
mkdir -p $nobackup/dataset2_result
eval sbatch -A b2012036 -p core -n 16 -t 5:00:00 --mail-user=dhany.saputra@ki.se --mail-type=ALL -J divide $somac/divide file1=$dreamdata/synthetic.challenge.set2.tumor.bam file2=$dreamdata/synthetic.challenge.set2.normal.bam chr=1-22,X,Y output=/proj/b2012036/nobackup/mutations/dataset2_splitchr
sleep 5; while squeue -u dhany | grep -q 'divide'; do counter=`expr $counter + 5`; if [[ $(( $counter % 60 )) == 0 ]];then echo "BAM splitting time elapsed = $(( $counter / 60 )) min"; fi; sleep 5; done; counter=`expr $counter + 5`; echo "Time elapsed for BAM splitting = $counter seconds"
cp $somac/config.cfg $nobackup/config.TN2
vi $nobackup/config.TN2 # Modify config.TN2 to use 8 cores (i.e. 8 for tumor file, 8 for normal file) and include $SNIC_TMP here
for i in {1,22,Y}
do
echo '#!/bin/bash -l' > $nobackup/dataset2_script/$i.txt
echo 'cp '$nobackup'/dataset2_splitchr/synthetic.challenge.set2.tumor.'$i'.bam $SNIC_TMP' >> $nobackup/dataset2_script/$i.txt
echo 'cp '$nobackup'/dataset2_splitchr/synthetic.challenge.set2.normal.'$i'.bam $SNIC_TMP' >> $nobackup/dataset2_script/$i.txt
echo 'cd '$somac >> $nobackup/dataset2_script/$i.txt
echo 'bash somac '$nobackup'/config.TN2 '$i >> $nobackup/dataset2_script/$i.txt
echo 'mv $SNIC_TMP/* '$nobackup'/dataset2_result' >> $nobackup/dataset2_script/$i.txt
eval sbatch -A b2012036 -p core -n 16 -t 24:00:00 --mail-user=dhany.saputra@ki.se --mail-type=ALL -J chr$i $nobackup/dataset2_script/$i.txt
done

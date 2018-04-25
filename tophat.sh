#!/bin/bash

# Default
# - input
OUTDIR="$(pwd)/bamfiles/tophat"
LOG="$(pwd)/log"
THREAD=5
MEMORY=16G
EMAIL=""
SAMPLE=""
LIBRARY=""
PLATFORM=""
MACHINE=""
TOPHATARG="--fusion-search --keep-fasta-order"
# - data
REF=/home/users/data/01_reference/human_g1k_v37/human_g1k_v37
INDEL=/home/users/data/02_annotation/01_GATK/01_golden_standard/Mills_and_1000G_gold_standard.indels.b37.vcf
# - Tools
TOPHAT=/home/users/kjyi/tools/tophat/tophat-2.1.0.Linux_x86_64/tophat2
PICARD=/home/users/tools/picard/dist/picard.jar
REF2=/home/users/data/01_reference/human_g1k_v37/human_g1k_v37.fasta 
SAMTOOLS=/home/users/tools/samtools-1.3/bin/samtools
GATK=/home/users/tools/gatk/gatk-3.5/GenomeAnalysisTK.jar
SNP=/home/users/data/02_annotation/01_GATK/02_db_snp/dbsnp_138.b37.vcf

USAGE1="""tophat.sh는 RNA-seq raw data를 reference에 mapping하는 루틴 process를 PBS에 등록해줍니다. Mapping이후 중복 read 표시,BQSR도 합니다.
"""
USAGE2="""
Usage: bnode0\$ tophat.sh [optional_arguments] fastq1 [fastaq2]

fastq file(s)             (필수. No flag required. Support *.gz file.)
-s | --sample_name        (필수. Output .bam file will follow this name)
-o | --outdir             $OUTDIR (Automatically generated if not exists)
-p | --platform           (null) $PLATFORM (e.g. ILLUMINA)
-l | --library            (null) $LIBRARY (e.g. TRUESEQNANO)
-m | --machine            (null) $MACHINE (e.g. HISEQ3000)
-e | --Email_address      (null) $EMAIL
-h | --help               More details"""
USAGE3="""
-T | --tophat-arg         기본: --fusion-search --keep-fasta-order (선언시 재선언 필요)
-r | --do_realign         기본은 실행하지 않음
-t | --thread		  $THREAD (Recommend 4 ~ 6. Not recommended under 4)
-M | --memory             $MEMORY
-s | --star               $STAR
-P | --picard             $PICARD
-g | --gatk               $GATK
-R | --reference_dir      $REF ---used in tophat
-H | --reference.fa       $REF2   ---used in gatk, picard
-i | --indel              $M1000G
-I | --indel_interval	  $INDELINTERVAL
-d | --dbsnp              $DBSNP
-S | --samtools           $SAMTOOLS
-L | --logdir             ./log (in current: $LOG)"""

ARGS=( "$@" ) # Because BASH_ARGV is read only
for i in "${!ARGS[@]}"; do
	case "${ARGS[i]}" in
    '')                  continue ;;  # Skip if element is empty (to pass '')
    -s|--sample_name)    SAMPLE="${ARGS[i+1]}"         ; unset 'ARGS[i+1]' ;;
    -o|--outdir)         OUTDIR="${ARGS[i+1]}"         ; unset 'ARGS[i+1]' ;;
    -p|--platform)       PLATFORM="${ARGS[i+1]}"       ; unset 'ARGS[i+1]' ;;
    -l|--library)        LIBRARY="${ARGS[i+1]}"        ; unset 'ARGS[i+1]' ;;
    -m|--machine)        MACHINE="${ARGS[i+1]}"        ; unset 'ARGS[i+1]' ;;
    -e|--mail_address)   EMAIL="${ARGS[i+1]}"          ; unset 'ARGS[i+1]' ;;
    -h|--help)           echo "$USAGE1$USAGE2$USAGE3"; exit 1              ;;
    -T|--tophat-arg)     TOPHATARGS="${ARGS[i+1]}"     ; unset 'ARGS[i+1]' ;;
    -r|--do_realign)     REALIGN="1"                                       ;;
    -t|--thread)         THREAD="${ARGS[i+1]}"         ; unset 'ARGS[i+1]' ;;
    -M|--memory)         MEMORY="${ARGS[i+1]}"         ; unset 'ARGS[i+1]' ;;
    -s|--star)           STAR="${ARGS[i+1]}"           ; unset 'ARGS[i+1]' ;;
    -P|--picard)         PICARD="${ARGS[i+1]}"         ; unset 'ARGS[i+1]' ;;
    -g|--gatk)           GATK="${ARGS[i+1]}"           ; unset 'ARGS[i+1]' ;;
    -R|--reference_dir)  REF="${ARGS[i+1]}"            ; unset 'ARGS[i+1]' ;;
    -i|--indel)          M1000G="${ARGS[i+1]}"          ; unset 'ARGS[i+1]' ;;
    -I|--indel_interval) INDEL_INTERVAL="${ARGS[i+1]}" ; unset 'ARGS[i+1]' ;;
    -d|--dbsnp)          DPSNP="${ARGS[i+1]}"          ; unset 'ARGS[i+1]' ;;
    -S|--samtools)       SAMTOOLS="${ARGS[i+1]}"       ; unset 'ARGS[i+1]' ;;
    -L|--logdir)         LOG="${ARGS[i+1]}"            ; unset 'ARGS[i+1]' ;;
    --)                  unset 'ARGS[i]';break ;; # End of arguments
    *)                   continue ;; # Skip unset if our argument is not matched
  esac
  unset 'ARGS[i]'
done

FASTQ=()
for i in "${!ARGS[@]}"; do FASTQ+=(${ARGS[i]}); done
if [[ "${FASTQ[0]}x" == "x" ]]; then echo "ERROR: No fastq submitted.$USAGE2"; exit 2; fi
if [[ "${SAMPLE}x" == "x" ]]; then echo "ERROR: Sample ID required.$USAGE2"; exit 2; fi
EMAILFLAG=$(echo $EMAIL|sed 's/./#PBS -m abe -M &/')
ADDLIBRARYINFO=$(echo $LIBRARY|sed "s/./RGLB=&/")
ADDPLATFORMINFO=$(echo $PLATFORM|sed "s/./RGPL=&/")
ADDMACHINEINFO=$(echo $MACHINE|sed "s/./RGPU=&/")
if [[ "${REALIGN}x" != "x" ]];then
	REALIGN="java -Xmx$MEMORY -jar $GATK -T RealignerTargetCreator \\
        -R $REF2 \\
        -I $OUTDIR/$SAMPLE/split.bam --known $INDEL \\
        -o $OUTDIR/$SAMPLE/interval -nt $THREAD && \\ 
java -Xmx$MEMORY -jar $GATK -T IndelRealigner \\
        -R $REF2 -known $INDEL \\
        -I $OUTDIR/$SAMPLE/split.bam \\
        -targetIntervals $OUTDIR/$SAMPLE/interval \\
        -o $OUTDIR/$SAMPLE/indel.bam && \\" 
else
	REALIGN="mv $OUTDIR/${SAMPLE}/split.bam $OUTDIR/${SAMPLE}/indel.bam && \\
	mv $OUTDIR/${SAMPLE}/split.bai $OUTDIR/${SAMPLE}/indel.bai && \\"
fi
mkdir -p $LOG
# ------------------------------------------------------------------------------
CODE="""#!/bin/bash
#PBS -q week               	# query
#PBS -l nodes=1:ppn=$THREAD
#PBS -l mem=$MEMORY
#PBS -V                    	# import shell environnment
#PBS -N tophat_${SAMPLE}		
#PBS -o ${LOG}/${SAMPLE}_tophat.log
#PBS -e ${LOG}/${SAMPLE}_tophat.err
$EMAILFLAG
cd \$PBS_O_WORKDIR
echo \"\$\(date\) \$ $0 $*\"

#-------------------------------------------------------------------------------
aaa='
mkdir -p $OUTDIR/$SAMPLE
$TOPHAT $TOPHATARGS \\
	--num-threads $THREAD \\
        -o $OUTDIR/$SAMPLE \\
        $REF "${FASTQ[0]}" "${FASTQ[1]}" && \\ 
java -Xmx$MEMORY -jar $PICARD AddOrReplaceReadGroups \\
        VALIDATION_STRINGENCY=LENIENT \\
	RGID=$SAMPLE RGSM=$SAMPLE $ADDLIBRARYINFO $ADDPLATFORMINFO $ADDMACHINEINFO \\
        I=$OUTDIR/$SAMPLE/accepted_hits.bam \\
        O=$OUTDIR/$SAMPLE/RG.bam && \\
$SAMTOOLS sort -@ $THREAD -o $OUTDIR/$SAMPLE/s.bam $OUTDIR/$SAMPLE/RG.bam && \\ 
rm $OUTDIR/$SAMPLE/RG.bam && \\
java -Xmx$MEMORY -jar $PICARD MarkDuplicates \\
        REMOVE_DUPLICATES=true REMOVE_SEQUENCING_DUPLICATES=true \\
	CREATE_INDEX=true \\
        I=$OUTDIR/$SAMPLE/s.bam \\
        O=$OUTDIR/$SAMPLE/marked.bam \\
        M=$OUTDIR/$SAMPLE/markdup_matrics.txt \\
        VALIDATION_STRINGENCY=LENIENT && \\ 
rm $OUTDIR/$SAMPLE/s.bam && \\
$SAMTOOLS index $OUTDIR/$SAMPLE/marked.bam && \\
'
java -Xmx$MEMORY -jar $PICARD ReorderSam \\
    I=$OUTDIR/$SAMPLE/marked.bam\\
    O=$OUTDIR/$SAMPLE/order.bam\\
    R=$REF2 \\
    CREATE_INDEX=TRUE && \\
java -Xmx$MEMORY -jar $GATK -T SplitNCigarReads \\
        -R $REF2 -I $OUTDIR/$SAMPLE/order.bam \\
        -o $OUTDIR/$SAMPLE/split.bam \\
        -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS && \\ 
$REALIGN
java -Xmx$MEMORY -jar $GATK -T BaseRecalibrator \\
        -R $REF2 \\
        -I $OUTDIR/$SAMPLE/indel.bam --knownSites $INDEL -knownSites $SNP \\
        -o $OUTDIR/$SAMPLE/table -nct $THREAD && \\ 
java -Xmx$MEMORY -jar $GATK -T PrintReads \\
        -R $REF2 \\
        -I $OUTDIR/$SAMPLE/indel.bam -BQSR $OUTDIR/$SAMPLE/table \\
        -o $OUTDIR/${SAMPLE}.bam -nct $THREAD && \\ 
# rm -rf $OUTDIR/$SAMPLE && \\
echo \"DONE \$\(date\)\"
# ------------------------------------------------------------------------------
"""
# submisssion ------------------------------------------------------------------
echo "$CODE" > ${LOG}/${SAMPLE}_tophat.sh
qsub ${LOG}/${SAMPLE}_tophat.sh


# $SAMTOOLS index $OUTDIR/${SAMPLE}.bam && \\

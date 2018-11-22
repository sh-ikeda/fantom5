### 詳細な遺伝子アノテーションを記述した hg38_liftover+new_CAGE_peaks_phase1and2_annot.txt の内容を、hg38_fair+new_CAGE_peaks_phase1and2_tpm_ann に取り込む

BEGIN {
    OFS = "\t"
    FS = "\t"
}

FNR==NR {
    if(FNR==1)
        $1 = "00Annotation"
    ann[$1,1]=$2;
    ann[$1,2]=$3;
    ann[$1,3]=$4;
    ann[$1,4]=$7;
    ann[$1,5]=$8;
    ann[$1,6]=$9;
    ann[$1,7]=$10
}

FNR!=NR && /^##/ {
    print
}

FNR!=NR && !/^##/ {
    printf $1;
    for(i=2;i<=7;i++)
        printf "\t" $i
    for(i=1;i<=7;i++) {
        if($0~/^01/||$0~/^02/)
            printf "\tNA"
        else if(ann[$1,i]=="")
            printf "\tNA"
        else
            printf "\t" ann[$1,i]
    }
    for(i=8;i<=NF;i++)
        printf("\t%s", $i)
    printf "\n"
}

END {
    
}

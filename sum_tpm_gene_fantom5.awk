### entrez gene id が一致している行の TPM 値を合算する

BEGIN {
    OFS = "\t"
    FS = "\t"

    prev_row[5] = ""
}

$1~/nnotation/ {
    print
}

/^hg/{
    if($5!=prev_row[5]) {
        if(prev_row[5]!="") {
            printf prev_row[1]
            for(i=2;i<=NF;i++)
                printf "\t" prev_row[i]
            printf "\n"
        }
        for(i=1;i<=NF;i++)
            prev_row[i] = $i
    }
    else if (prev_row[5]!="") {
        for(i=15;i<=NF;i++)
            prev_row[i] += $i
    }
    n = NF
}

END {
    printf prev_row[1]
    for(i=2;i<=n;i++)
        printf "\t" prev_row[i]
    printf "\n"
}

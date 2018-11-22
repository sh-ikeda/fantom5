### replicate の値を median でまとめる。

BEGIN {
    OFS = "\t"
    FS = "\t"
}

FNR==1 {
    for(i=1; i<=14; i++)
        row[FNR, i] = $i
    for(i=15; i<=NF; i++) {
        idx = index($i, "CNhs")
        row[FNR, i] = substr($i, idx, index($i, "hg38")-idx-1)
    }
}

# 15 列目から TPM
# 2~5 行目がアノテーション
FNR<=5 && FNR>=2 {
    for(i=15; i<=NF; i++) {
        if(FNR != 5)
            row[FNR, i] = $i
        if(!name[i])
            name[i] = $i
        else if($i != "NA")
            name[i] = name[i] "|" $i
        else if($i=="NA" && FNR>=4)
            row[FNR-1, i] = "NA"
    }
}

FNR==5 { # 6 に入る前
    for(i=15; i<=NF; i++) {
        # 一番後ろの | から後ろを取り除く
        # ただし、アノテーションがひとつしかない場合は必要ない
        if(index(name[i], "|")!=0)
            name[i] = substr(name[i], 1, match(name[i], "\\|[^\\|]+$")-1)
        #print name[i]
    }

    sep[1] = 15 # 15 列目から１つ目の区切りが始まる
    nsep = 2
    prev = name[15]
    for(i=16; i<=NF; i++) {
        if(name[i]!=prev) {
            sep[nsep] = i
            nsep++
        }
        prev = name[i]
    }
    sep[nsep] = NF+1

    printf row[1, 1]
    for(i=2; i<=14; i++)
        printf "\t" row[1, i]
    for(j=1; j<nsep; j++)
        printf "\t" row[1, sep[j]] "-" row[1, sep[j+1]-1]
    printf "\n"

    for(k=2; k<=4; k++){
        printf "annotation" k-1 "\t\t\t\t\t\t\t\t\t\t\t\t\t"
        for(j=1; j<nsep; j++)
            printf "\t" row[k, sep[j]]
        printf "\n"
    }

    printf "# of sample\t\t\t\t\t\t\t\t\t\t\t\t\t"
    for(j=1; j<nsep; j++)
        printf "\t" sep[j+1]-sep[j]
    printf "\n"
}

FNR>=6 {
    printf $1
    for(i=2; i<=14; i++)
        printf "\t" $i
    for(j=1; j<nsep; j++) {
        for(i=sep[j]; i<sep[j+1]; i++)
            tpm[i-sep[j]+1] = $i
        n=asort(tpm, result)

        if(n%2==0)
            med = (result[n/2]+result[1+n/2])/2
        else
            med = result[(n+1)/2]
        delete(tpm)
        printf "\t" med
    }
    printf "\n"
}

END {
    
}

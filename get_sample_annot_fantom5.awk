### FANTOM5 hg38 のファイルに適用
### 上部の ## 行に記載されているサンプルアノテーションを、サンプル名のカラムの下に取り込む
### awk -f get_sample_annot_fantom5.awk -v field=4 input
### ヒトのデータではフィールドは最大で４つ。マウスでは６。field 引数で指定のこと。満たないものは NA で埋める

BEGIN {
    OFS = "\t"
    FS = "\t"
    if(!field) {
        print "'-v field=NUM' is missing." > "/dev/stderr"
        exit(-1)
    }
}

/^#/ && /tpm/ {
    left = index($0, "[")+1
    right = index($0, "]")-1
    sample = substr($0, left, right-left+1)

    left = index($0, ") of ")+5
    right = index(substr($0, left), ".CNhs")-1
    ann = substr($0, left, right)
    # print ann

    # ", "区切りで入力されているアノテーション情報を分解して配列に格納する
    prev = 0

    for(i=1; i<=field; i++) {
        comma = index(substr(ann, prev+1), ", ")
        if(comma==0) {
            ann_of[sample, i] = substr(ann, prev+1)
            for(i=i+1; i<=field; i++)
                ann_of[sample, i] = "NA"
        }
        else
            ann_of[sample, i] = substr(ann, prev+1, comma-1)
        prev = prev+comma+1
    }

    # for(i=1;i<=field;i++)
    #     printf ann_of[sample, i] "\t"
    # printf "\n"
}

/^00Annotation/ {
    print
    for(i=1; i<=field; i++) {
        printf "annotation" i
        for(j=2; j<=NF; j++)
            printf "\t" ann_of[$j, i]
        printf "\n"
    }
}

!/^#/ && !/^00Annotation/ {
    print
}

END {
    
}

# fantom5
FANTOM5 の TPM データを RefEx に収載する

配布サイトより、ヒトとマウスのデータをダウンロード。
http://fantom.gsc.riken.jp/5/datafiles/reprocessed/hg38_v5/extra/CAGE_peaks_expression/hg38_fair+new_CAGE_peaks_phase1and2_tpm_ann.osc.txt.gz
http://fantom.gsc.riken.jp/5/datafiles/reprocessed/mm10_v5/extra/CAGE_peaks_expression/mm10_fair+new_CAGE_peaks_phase1and2_tpm_ann.osc.txt.gz

CAGE ピークに対するアノテーションのうち、Gene symbol など一部は別ファイルに記載されている。
http://fantom.gsc.riken.jp/5/datafiles/reprocessed/hg38_v5/extra/CAGE_peaks_annotation/hg38_liftover+new_CAGE_peaks_phase1and2_annot.txt
http://fantom.gsc.riken.jp/5/datafiles/reprocessed/mm10_v5/extra/CAGE_peaks_annotation/mm10_liftover+new_CAGE_peaks_phase1and2_annot.txt

このアノテーションファイルの以下の情報を発現量のファイルに取り込む。

| 列目 | 内容            |
------|-----------------
|    2 | Transcript_name |
|    3 | Distance        |
|    4 | GeneID          |
|    7 | Gene_name       |
|    8 | Gene_symbol     |
|    9 | Gene_synonyms   |
|   10 | Gene_source     |
```
$ awk -f get_detail_annot_fantom5.awk hg38_liftover+new_CAGE_peaks_phase1and2_annot.txt hg38_fair+new_CAGE_peaks_phase1and2_tpm_ann.osc.txt > hg38_fair+new_CAGE_peaks_phase1and2_tpm_ann_plus.osc.txt
```

ファイル冒頭のコメント行に、サンプル名の説明がある。
コメント行の[]の中身が列名と一致するので、それをキーとし、その行の", "区切りのアノテーション情報をバリューとして対応付ける。
アノテーション情報を", "で区切り、サンプル名の下の行にそれぞれ一行ずつ使って記述する。
```
$ awk -f get_sample_annot_fantom5.awk -v field=4 hg38_fair+new_CAGE_peaks_phase1and2_tpm_ann_plus.osc.txt > fantom5_hg38_all_annotated.tsv
$ awk -f get_sample_annot_fantom5.awk -v field=6 mm10_fair+new_CAGE_peaks_phase1and2_tpm_ann_plus.osc.txt > fantom5_mm10_all_annotated.tsv
```
Entrez gene ID ($5) が NA である行(遺伝子が割り当てられていない CAGE ピーク)は消去。
```
$ awk -F "\t" '$5!="NA"{print $0}' fantom5_hg38_all_annotated.tsv > temp.txt
```
５行目までヘッダなので除いて、５列目(Entrez gene id)でソート
```
$ (head -5 temp.txt && tail -n +6 temp.txt | sort -t$'\t' -k 5,5) > fantom5_hg38_all_annotated_sorted_by_geneid.tsv
```
gene ID が同じである行の TPM を足し合わせる。
```
$ awk -f sum_tpm_gene_fantom5.awk fantom5_hg38_all_annotated_sorted_by_geneid.tsv > fantom5_hg38_all_annotated_sum.tsv
```
replicate の TPM を median にまとめたい。
単純に一番後ろのアノテーションを replicate の情報とみなすようにしたいが、必ずしもそのようにアノテーションが付けられていないので、Excel を使って手動で修正する。
```
$ head -5 fantom5_hg38_all_annotated_sum.tsv > fantom5_hg38_header.tsv

# fantom5_hg38_header.tsv を手動で修正、fantom5_hg38_header_edited.tsv として保存

$ tail -n +6 fantom5_hg38_all_annotated_sum.tsv > temp.txt
$ echo "" >> fantom5_hg38_header_edited.tsv
$ cat fantom5_hg38_header_edited.tsv temp.txt > temp2.txt
$ mv temp2.txt fantom5_hg38_all_annotated_sum.tsv
```
アノテーションを修正した結果、列の入れ替えが必要なところが生じるのでソートする。
```
$ python sort_columns.py fantom5_hg38_all_annotated_sum.tsv fantom5_hg38_all_annotated_sum_edited.tsv
```
これを用い、replicate の TPM を median にまとめる。
```
$ awk -f assemble_as_median_fantom5.awk fantom5_hg38_all_annotated_sum_edited.tsv > fantom5_hg38_all_annotated_median_edited.tsv
```

Pending:  
CAGE ピークに対して、複数の Gene ID が割り当てられている場合がある。  
CAGE のピークの位置の近くに複数の遺伝子があり、実際にどちらの遺伝子の発現をそのピークが表しているか判断ができない場合など。  
どのように扱うかは保留中。(理研粕川さんと相談)

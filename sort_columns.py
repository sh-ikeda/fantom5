import numpy as np
import pandas as pd
import sys

args = sys.argv
infile = args[1]
outfile = args[2]

a=[0]
a.extend(list(range(14, 1843)))
data = pd.read_table(infile, header=0, index_col=0, sep='\t', dtype = 'object', usecols=a)
data_s = data.sort_values(['annotation1','annotation2','annotation3','annotation4'], axis=1)
annot = pd.read_table(infile, header=0, index_col=0, sep='\t', dtype = 'object', usecols=range(0, 14))
data_c = pd.concat([annot, data_s], axis=1)
data_c.to_csv(outfile, sep='\t', na_rep="NA")

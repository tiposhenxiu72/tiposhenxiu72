type 1.1_WITH_TEMP(MCMDLCD).txt>>all.sql
type A_SELECT_EXCLUSION.txt>>all.sql
db2 -tvf all.sql
del all.sql

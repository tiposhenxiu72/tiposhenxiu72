type 1.2_WITH_TEMP(PRTNO).txt>>all.sql
type A_SELECT_EXCLUSION.txt>>all.sql
db2 -tvf all.sql
del all.sql

type 1.2_WITH_TEMP(PRTNO).txt>all.sql
type 2_WITH_FINALBLCKLIST.txt>>all.sql
type 3_WITH_SPLRLIST.txt>>all.sql
type 4.2_WITH_OLDPRTLIST(PS).txt>>all.sql
type 5.2_WITH_RESULT_PS.txt>>all.sql
type 6.2_SELECT_PS.txt>>all.sql
db2 -tvf all.sql
del all.sql

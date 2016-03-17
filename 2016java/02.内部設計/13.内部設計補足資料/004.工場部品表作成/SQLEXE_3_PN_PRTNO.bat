type 1.2_WITH_TEMP(PRTNO).txt>all.sql
type 2_WITH_FINALBLCKLIST.txt>>all.sql
type 3_WITH_SPLRLIST.txt>>all.sql
type 4.1_WITH_OLDPRTLIST(PN).txt>>all.sql
type 5.1_WITH_RESULT_PN.txt>>all.sql
type 6.1_SELECT_PN.txt>>all.sql
db2 -tvf all.sql
del all.sql

# expData.sql was originally generated by the autoSql program, which also 
# generated expData.c and expData.h.  This creates the database representation of
# an object which can be loaded and saved from RAM in a fairly 
# automatic way.

#Expression data (no mapping, just spots)
CREATE TABLE expData (
    name varchar(255) not null,	# Name of gene/target/probe etc.
    expCount int unsigned not null,	# Number of scores
    expScores longblob not null,	# Scores. May be absolute or relative ratio
              #Indices
    INDEX(name(10))
);

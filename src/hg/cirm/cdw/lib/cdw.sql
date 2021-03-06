# cdw.sql was originally generated by the autoSql program, which also 
# generated cdw.c and cdw.h.  This creates the database representation of
# an object which can be loaded and saved from RAM in a fairly 
# automatic way.

#Settings used to configure warehouse
CREATE TABLE cdwSettings (
    id int unsigned auto_increment,	# Settings ID
    name varchar(255) not null,	# Settings name, can't be reused
    val varchar(255) not null,	# Settings value, some undefined but not huge thing
              #Indices
    PRIMARY KEY(id),
    UNIQUE(name),
    INDEX(val)
);

#Someone who submits files to or otherwise interacts with big data warehouse
CREATE TABLE cdwUser (
    id int unsigned auto_increment,	# Autoincremented user ID
    email varchar(255) not null,	# Email address - required
    uuid char(37) not null,	# Help to synchronize us with Stanford.
    isAdmin tinyint not null,	# If true the use can modify other people's files too.
    primaryGroup int unsigned not null,	# If this is non-zero then we'll make files with this group association.
              #Indices
    PRIMARY KEY(id),
    UNIQUE(email),
    INDEX(uuid)
);

#A group in the access control sense
CREATE TABLE cdwGroup (
    id int unsigned auto_increment,	# Autoincremented user ID
    name varchar(255) not null,	# Symbolic name for group, should follow rules of a lowercase C symbol.
    description longblob not null,	# Description of group
              #Indices
    PRIMARY KEY(id),
    UNIQUE(name)
);

#Association table between cdwFile and cdwGroup
CREATE TABLE cdwGroupFile (
    fileId int unsigned not null,	# What is the file
    groupId int unsigned not null,	# What is the group
              #Indices
    INDEX(fileId)
);

#Association table between cdwGroup and cdwUser
CREATE TABLE cdwGroupUser (
    userId int unsigned not null,	# What is the user
    groupId int unsigned not null,	# What is the group
              #Indices
    INDEX(userId),
    INDEX(groupId)
);

#A contributing lab
CREATE TABLE cdwLab (
    id int unsigned auto_increment,	# Autoincremented user ID
    name varchar(255) not null,	# Shorthand name for lab, all lower case
    pi varchar(255) not null,	# Principle investigator responsible for lab
    institution varchar(255) not null,	# University or other institution hosting lab
    url varchar(255) not null,	# URL of lab page
              #Indices
    PRIMARY KEY(id),
    UNIQUE(name)
);

#A script that is authorized to submit on behalf of a user
CREATE TABLE cdwScriptRegistry (
    id int unsigned auto_increment,	# Autoincremented script ID
    userId int unsigned not null,	# Associated user
    name varchar(255) not null,	# Script name - unique in system and autogenerated
    description longblob not null,	# Script description
    secretHash varchar(255) not null,	# Hashed script password
    submitCount int not null,	# Number of submissions attempted
              #Indices
    PRIMARY KEY(id),
    INDEX(userId),
    UNIQUE(name)
);

#A web host we have collected files from - something like www.ncbi.nlm.gov or google.com
CREATE TABLE cdwHost (
    id int unsigned auto_increment,	# Autoincremented host id
    name varchar(255) not null,	# Name (before DNS lookup)
    lastOkTime bigint not null,	# Last time host was ok in seconds since 1970
    lastNotOkTime bigint not null,	# Last time host was not ok in seconds since 1970
    firstAdded bigint not null,	# Time host was first seen
    errorMessage longblob not null,	# If non-empty contains last error message from host. If empty host is ok
    openSuccesses bigint not null,	# Number of times files have been opened ok from this host
    openFails bigint not null,	# Number of times files have failed to open from this host
    historyBits bigint not null,	# Open history with most recent in least significant bit. 0 for connection failed, 1 for success
    paraFetchStreams int not null,	# Number of open streams for paraFetch command.  10 for most places, 30 for Barcelona
              #Indices
    PRIMARY KEY(id),
    UNIQUE(name)
);

#An external data directory we have collected a submit from
CREATE TABLE cdwSubmitDir (
    id int unsigned auto_increment,	# Autoincremented id
    url longblob not null,	# Web-mounted directory. Includes protocol, host, and final '/'
    hostId int unsigned not null,	# Id of host it's on
    lastOkTime bigint not null,	# Last time submit dir was ok in seconds since 1970
    lastNotOkTime bigint not null,	# Last time submit dir was not ok in seconds since 1970
    firstAdded bigint not null,	# Time submit dir was first seen
    errorMessage longblob not null,	# If non-empty contains last error message from dir. If empty dir is ok
    openSuccesses bigint not null,	# Number of times files have been opened ok from this dir
    openFails bigint not null,	# Number of times files have failed to open from this dir
    historyBits bigint not null,	# Open history with most recent in least significant bit. 0 for upload failed, 1 for success
              #Indices
    PRIMARY KEY(id),
    INDEX(url(64)),
    INDEX(hostId)
);

#Where we keep expanded metadata tags for each file, though many share.
CREATE TABLE cdwMetaTags (
    id int unsigned auto_increment,	# Autoincrementing table id
    md5 char(32) not null,	# md5 sum of tags string
    tags longblob not null,	# CGI encoded name=val pairs from manifest
              #Indices
    PRIMARY KEY(id),
    INDEX(md5)
);

#A file we are tracking that we intend to and maybe have uploaded
CREATE TABLE cdwFile (
    id int unsigned auto_increment,	# Autoincrementing file id
    submitId int unsigned not null,	# Links to id in submit table
    submitDirId int unsigned not null,	# Links to id in submitDir table
    userId int unsigned not null,	# Id in user table of file owner
    submitFileName longblob not null,	# File name in submit relative to submit dir
    cdwFileName longblob not null,	# File name in big data warehouse relative to cdw root dir
    startUploadTime bigint not null,	# Time when upload started - 0 if not started
    endUploadTime bigint not null,	# Time when upload finished - 0 if not finished
    updateTime bigint not null,	# Update time (on system it was uploaded from)
    size bigint not null,	# File size in manifest
    md5 char(32) not null,	# md5 sum of file contents
    tags longblob not null,	# CGI encoded name=val pairs from manifest
    metaTagsId int unsigned not null,	# ID of associated metadata tags
    errorMessage longblob not null,	# If non-empty contains last error message from upload. If empty upload is ok
    deprecated varchar(255) not null,	# If non-empty why you shouldn't use this file any more.
    replacedBy int unsigned not null,	# If non-zero id of file that replaces this one.
    userAccess tinyint not null,	# 0 - no, 1 - read, 2 - read/write
    groupAccess tinyint not null,	# 0 - no, 1 - read, 2 - read/write
    allAccess tinyint not null,	# 0 - no, 1 - read, 2 - read/write
              #Indices
    PRIMARY KEY(id),
    INDEX(submitId),
    INDEX(submitDirId),
    INDEX(userId),
    INDEX(submitFileName(64)),
    INDEX(cdwFileName(32)),
    INDEX(md5)
);

#A data submit, typically containing many files.  Always associated with a submit dir.
CREATE TABLE cdwSubmit (
    id int unsigned auto_increment,	# Autoincremented submit id
    url longblob not null,	# Url to validated.txt format file. We copy this file over and give it a fileId if we can.
    startUploadTime bigint not null,	# Time at start of submit
    endUploadTime bigint not null,	# Time at end of upload - 0 if not finished
    userId int unsigned not null,	# Connects to user table id field
    manifestFileId int unsigned not null,	# Points to metadata.txt file for submit.
    metaFileId int unsigned not null,	# Points to meta.txt file for submit
    submitDirId int unsigned not null,	# Points to the submitDir
    fileCount int unsigned not null,	# Number of files that will be in submit if it were complete.
    oldFiles int unsigned not null,	# Number of files in submission that were already in warehouse.
    newFiles int unsigned not null,	# Number of files in submission that are newly uploaded.
    byteCount bigint not null,	# Total bytes in submission including old and new
    oldBytes bigint not null,	# Bytes in old files.
    newBytes bigint not null,	# Bytes in new files (so far).
    errorMessage longblob not null,	# If non-empty contains last error message. If empty submit is ok
    fileIdInTransit int unsigned not null,	# cdwFile.id of file currently being transferred or zero
    metaChangeCount int unsigned not null,	# Number of files where metadata changed by submission
              #Indices
    PRIMARY KEY(id),
    INDEX(url(32)),
    INDEX(userId),
    INDEX(manifestFileId),
    INDEX(metaFileId),
    INDEX(submitDirId)
);

#Subscribers can have programs that are called at various points during data submission
CREATE TABLE cdwSubscriber (
    id int unsigned auto_increment,	# ID of subscriber
    name varchar(255) not null,	# Name of subscriber
    runOrder double not null,	# Determines order subscribers run in. In case of tie lowest id wins.
    filePattern varchar(255) not null,	# A string with * and ? wildcards to match files we care about
    dirPattern varchar(255) not null,	# A string with * and ? wildcards to match hub dir URLs we care about
    tagPattern longblob not null,	# A cgi-encoded string of tag=wildcard pairs.
    onFileEndUpload varchar(255) not null,	# A unix command string to run with a %u where file id goes
              #Indices
    PRIMARY KEY(id)
);

#An assembly - includes reference to a two bit file, and a little name and summary info.
CREATE TABLE cdwAssembly (
    id int unsigned auto_increment,	# Assembly ID
    taxon int unsigned not null,	# NCBI taxon number
    name varchar(255) not null,	# Some human readable name to distinguish this from other collections of DNA
    ucscDb varchar(255) not null,	# Which UCSC database (mm9?  hg19?) associated with it.
    twoBitId int unsigned not null,	# File ID of associated twoBit file
    baseCount bigint not null,	# Count of bases including N's
    realBaseCount bigint not null,	# Count of non-N bases in assembly
    seqCount int unsigned not null,	# Number of chromosomes or other distinct sequences in assembly
              #Indices
    PRIMARY KEY(id)
);

#A biosample - not much info here, just enough to drive analysis pipeline
CREATE TABLE cdwBiosample (
    id int unsigned auto_increment,	# Biosample id
    term varchar(255) not null,	# Human readable..
    taxon int unsigned not null,	# NCBI taxon number - 9606 for human.
    sex varchar(255) not null,	# One letter code: M male, F female, B both, U unknown
              #Indices
    PRIMARY KEY(id),
    INDEX(term)
);

#An experiment - ideally will include a couple of biological replicates. Downloaded from Stanford.
CREATE TABLE cdwExperiment (
    accession char(16) not null,	# ID shared with metadata system.
    dataType varchar(255) not null,	# Something liek RNA-seq, DNase-seq, ChIP-seq. Computed at UCSC.
    lab varchar(255) not null,	# Lab PI name and institution. Is lab.title at Stanford.
    biosample varchar(255) not null,	# Cell line name, tissue source, etc. Is biosample_term_name at Stanford.
    rfa varchar(255) not null,	# Something like 'ENCODE2' or 'ENCODE3'.  Is award.rfa at Stanford.
    assayType varchar(255) not null,	# Similar to dataType. Is assay_term_name at Stanford.
    ipTarget varchar(255) not null,	# The target for the immunoprecipitation in ChIP & RIP.
    control varchar(255) not null,	# Primary control for experiment.  Usually another experiment accession.
              #Indices
    UNIQUE(accession)
);

#A file that has been uploaded, the format checked, and for which at least minimal metadata exists
CREATE TABLE cdwValidFile (
    id int unsigned auto_increment,	# ID of validated file
    licensePlate char(16) not null,	# A abc123 looking license-platish thing.
    fileId int unsigned not null,	# Pointer to file in main file table
    format varchar(255) not null,	# What format it's in from manifest
    outputType varchar(255) not null,	# What output_type it is from manifest
    experiment varchar(255) not null,	# What experiment it's in from manifest
    replicate varchar(255) not null,	# What replicate it is from manifest.  Values 1,2,3... pooled, or ''
    enrichedIn varchar(255) not null,	# The enriched_in tag from manifest
    ucscDb varchar(255) not null,	# Something like hg19 or mm9
    itemCount bigint not null,	# # of items in file: reads for fastqs, lines for beds, bases w/data for wig.
    basesInItems bigint not null,	# # of bases in items
    sampleCount bigint not null,	# # of items in sample if we are just subsampling as we do for reads.
    basesInSample bigint not null,	# # of bases in our sample
    sampleBed varchar(255) not null,	# Path to a temporary bed file holding sample items
    mapRatio double not null,	# Proportion of items that map to genome
    sampleCoverage double not null,	# Proportion of assembly covered by at least one item in sample
    depth double not null,	# Estimated genome-equivalents covered by possibly overlapping data
    singleQaStatus tinyint not null,	# 0 = untested, 1 =  pass, -1 = fail, 2 = forced pass, -2 = forced fail
    replicateQaStatus tinyint not null,	# 0 = untested, 1 = pass, -1 = fail, 2 = forced pass, -2 = forced fail
    part varchar(255) not null,	# Manifest's file_part. Values 1,2,3... Used for fastqs split for analysis
    pairedEnd varchar(255) not null,	# The paired_end tag from the manifest.  Values 1,2 or ''
    qaVersion tinyint not null,	# Version of QA pipeline making status decisions
    uniqueMapRatio double not null,	# Fraction of reads that map uniquely to genome for bams and fastqs
    lane varchar(255) not null,	# What sequencing lane if any associated with this file.
              #Indices
    PRIMARY KEY(id),
    INDEX(licensePlate),
    INDEX(fileId),
    INDEX(format(12)),
    INDEX(outputType(16)),
    INDEX(experiment(16))
);

#info on a file in fastq short read format beyond what's in cdwValidFile
CREATE TABLE cdwFastqFile (
    id int unsigned auto_increment,	# ID in this table
    fileId int unsigned not null,	# ID in cdwFile table
    sampleCount bigint not null,	# # of reads in sample.
    basesInSample bigint not null,	# # of bases in sample.
    sampleFileName varchar(255) not null,	# Name of file containing sampleCount randomly selected items from file.
    readCount bigint not null,	# # of reads in file
    baseCount bigint not null,	# # of bases in all reads added up
    readSizeMean double not null,	# Average read size
    readSizeStd double not null,	# Standard deviation of read size
    readSizeMin int not null,	# Minimum read size
    readSizeMax int not null,	# Maximum read size
    qualMean double not null,	# Mean quality scored as 10*-log10(errorProbability) or close to it.  >25 is good
    qualStd double not null,	# Standard deviation of quality
    qualMin double not null,	# Minimum observed quality
    qualMax double not null,	# Maximum observed quality
    qualType varchar(255) not null,	# For fastq files either 'sanger' or 'illumina'
    qualZero int not null,	# For fastq files offset to get to zero value in ascii encoding
    atRatio double not null,	# Ratio of A+T to total sequence (not including Ns)
    aRatio double not null,	# Ratio of A to total sequence (including Ns)
    cRatio double not null,	# Ratio of C to total sequence (including Ns)
    gRatio double not null,	# Ratio of G to total sequence (including Ns)
    tRatio double not null,	# Ratio of T to total sequence (including Ns)
    nRatio double not null,	# Ratio of N or . to total sequence
    qualPos longblob not null,	# Mean value for each position in a read up to some max.
    aAtPos longblob not null,	# % of As at each pos
    cAtPos longblob not null,	# % of Cs at each pos
    gAtPos longblob not null,	# % of Gs at each pos
    tAtPos longblob not null,	# % of Ts at each pos
    nAtPos longblob not null,	# % of '.' or 'N' at each pos
              #Indices
    PRIMARY KEY(id),
    UNIQUE(fileId)
);

#Info on what is in a bam file beyond whet's in cdwValidFile
CREATE TABLE cdwBamFile (
    id int unsigned auto_increment,	# ID in this table
    fileId int unsigned not null,	# ID in cdwFile table.
    isPaired tinyint not null,	# Set to 1 if paired reads, 0 if single
    isSortedByTarget tinyint not null,	# Set to 1 if sorted by target,pos
    readCount bigint not null,	# # of reads in file
    readBaseCount bigint not null,	# # of bases in all reads added up
    mappedCount bigint not null,	# # of reads that map
    uniqueMappedCount bigint not null,	# # of reads that map to a unique position
    readSizeMean double not null,	# Average read size
    readSizeStd double not null,	# Standard deviation of read size
    readSizeMin int not null,	# Minimum read size
    readSizeMax int not null,	# Maximum read size
    u4mReadCount int not null,	# Uniquely-mapped 4 million read actual read # (usually 4M)
    u4mUniquePos int not null,	# Unique positions in target of the 4M reads that map to single pos
    u4mUniqueRatio double not null,	# u4mUniqPos/u4mReadCount - measures library diversity
    targetBaseCount bigint not null,	# Count of bases in mapping target
    targetSeqCount int unsigned not null,	# Number of chromosomes or other distinct sequences in mapping target
              #Indices
    PRIMARY KEY(id),
    UNIQUE(fileId)
);

#Info on what is in a vcf file beyond whet's in cdwValidFile
CREATE TABLE cdwVcfFile (
    id int unsigned auto_increment,	# ID in this table
    fileId int unsigned not null,	# ID in cdwFile table.
    vcfMajorVersion int not null,	# VCF file major version
    vcfMinorVersion int not null,	# VCF file minor version
    genotypeCount int not null,	# How many genotypes of data
    itemCount bigint not null,	# Number of records in VCF file
    chromsHit int not null,	# Number of chromosomes (or contigs) with data
    passItemCount bigint not null,	# Number of records that PASS listed filter
    passRatio double not null,	# passItemCount/itemCount
    snpItemCount bigint not null,	# Number of records that are just single base substitution, no indels
    snpRatio double not null,	# snpItemCount/itemCount
    sumOfSizes bigint not null,	# The sum of sizes of all records
    basesCovered bigint not null,	# Bases with data. Equals sumOfSizes if no overlap of records.
    xBasesCovered int not null,	# Number of bases of chrX covered
    yBasesCovered int not null,	# Number of bases of chrY covered
    mBasesCovered int not null,	# Number of bases of chrM covered
    haploidCount bigint not null,	# Number of genotype calls that are haploid
    haploidRatio double not null,	# Ratio of hapload to total calls
    phasedCount bigint not null,	# Number of genotype calls that are phased
    phasedRatio double not null,	# Ration of phased calls to total calls
    gotDepth tinyint not null,	# If true then have DP value in file and in depth stats below
    depthMin double not null,	# Min DP reported depth
    depthMean double not null,	# Mean DP value
    depthMax double not null,	# Max DP value
    depthStd double not null,	# Standard DP deviation
              #Indices
    PRIMARY KEY(id),
    UNIQUE(fileId)
);

#Record of a QA failure.
CREATE TABLE cdwQaFail (
    id int unsigned auto_increment,	# ID of failure
    fileId int unsigned not null,	# File that failed
    qaVersion int unsigned not null,	# QA pipeline version
    reason longblob not null,	# reason for failure
              #Indices
    PRIMARY KEY(id),
    INDEX(fileId)
);

#A target for our enrichment analysis.
CREATE TABLE cdwQaEnrichTarget (
    id int unsigned auto_increment,	# ID of this enrichment target
    assemblyId int unsigned not null,	# Which assembly this goes to
    name varchar(255) not null,	# Something like 'exon' or 'promoter'
    fileId int unsigned not null,	# A simple BED 3 format file that defines target. Bases covered are unique
    targetSize bigint not null,	# Total number of bases covered by target
              #Indices
    PRIMARY KEY(id),
    INDEX(assemblyId),
    INDEX(name)
);

#An enrichment analysis applied to file.
CREATE TABLE cdwQaEnrich (
    id int unsigned auto_increment,	# ID of this enrichment analysis
    fileId int unsigned not null,	# File we are looking at skeptically
    qaEnrichTargetId int unsigned not null,	# Information about a target for this analysis
    targetBaseHits bigint not null,	# Number of hits to bases in target
    targetUniqHits bigint not null,	# Number of unique bases hit in target
    coverage double not null,	# Coverage of target - just targetUniqHits/targetSize
    enrichment double not null,	# Amount we hit target/amount we hit genome
    uniqEnrich double not null,	# coverage/sampleCoverage
              #Indices
    PRIMARY KEY(id),
    INDEX(fileId)
);

#A target for our contamination analysis.
CREATE TABLE cdwQaContamTarget (
    id int unsigned auto_increment,	# ID of this contamination target
    assemblyId int unsigned not null,	# Assembly we're aligning against to check  for contamination.
              #Indices
    PRIMARY KEY(id),
    UNIQUE(assemblyId)
);

#Results of contamination analysis of one file against one target
CREATE TABLE cdwQaContam (
    id int unsigned auto_increment,	# ID of this contamination analysis
    fileId int unsigned not null,	# File we are looking at skeptically
    qaContamTargetId int unsigned not null,	# Information about a target for this analysis
    mapRatio double not null,	# Proportion of items that map to target
              #Indices
    PRIMARY KEY(id),
    INDEX(fileId)
);

#What percentage of data set aligns to various repeat classes.
CREATE TABLE cdwQaRepeat (
    id int unsigned auto_increment,	# ID of this repeat analysis.
    fileId int unsigned not null,	# File we are analysing.
    repeatClass varchar(255) not null,	# RepeatMasker high end classification,  or 'total' for all repeats.
    mapRatio double not null,	# Proportion that map to this repeat.
              #Indices
    PRIMARY KEY(id),
    INDEX(fileId)
);

#A comparison of the amount of overlap between two samples that cover ~0.1% to 10% of target.
CREATE TABLE cdwQaPairSampleOverlap (
    id int unsigned auto_increment,	# Id of this qa pair
    elderFileId int unsigned not null,	# Id of elder (smaller fileId) in correlated pair
    youngerFileId int unsigned not null,	# Id of younger (larger fileId) in correlated pair
    elderSampleBases bigint not null,	# Number of bases in elder sample
    youngerSampleBases bigint not null,	# Number of bases in younger sample
    sampleOverlapBases bigint not null,	# Number of bases that overlap between younger and elder sample
    sampleSampleEnrichment double not null,	# Amount samples overlap more than expected.
              #Indices
    PRIMARY KEY(id),
    INDEX(elderFileId),
    INDEX(youngerFileId)
);

#A correlation between two files of the same type.
CREATE TABLE cdwQaPairCorrelation (
    id int unsigned auto_increment,	# Id of this correlation pair
    elderFileId int unsigned not null,	# Id of elder (smaller fileId) in correlated pair
    youngerFileId int unsigned not null,	# Id of younger (larger fileId) in correlated pair
    pearsonInEnriched double not null,	# Pearson's R inside enriched areas where there is overlap
    pearsonOverall double not null,	# Pearson's R over all places where both have data
    pearsonClipped double not null,	# Pearson's R clipped at two standard deviations up from the mean
              #Indices
    PRIMARY KEY(id),
    INDEX(elderFileId),
    INDEX(youngerFileId)
);

#Information about two paired-end fastqs
CREATE TABLE cdwQaPairedEndFastq (
    id int unsigned auto_increment,	# Id of this set of paired end files
    fileId1 int unsigned not null,	# Id of first in pair
    fileId2 int unsigned not null,	# Id of second in pair
    concordance double not null,	# % of uniquely aligning reads where pairs nearby and point right way
    distanceMean double not null,	# Average distance between reads
    distanceStd double not null,	# Standard deviation of distance
    distanceMin double not null,	# Minimum distance
    distanceMax double not null,	# Maximum distatnce
    recordComplete tinyint not null,	# Flag to avoid a race condition. Ignore record if this is 0
              #Indices
    PRIMARY KEY(id),
    INDEX(fileId1),
    INDEX(fileId2)
);

#Information about proportion of signal in a wig that lands under spots in a peak or bed file
CREATE TABLE cdwQaWigSpot (
    id int unsigned auto_increment,	# Id of this wig/spot intersection
    wigId int unsigned not null,	# Id of bigWig file
    spotId int unsigned not null,	# Id of a bigBed file probably broadPeak or narrowPeak
    spotRatio double not null,	# Ratio of signal in spots to total signal,  between 0 and 1
    enrichment double not null,	# Enrichment in spots compared to genome overall
    basesInGenome bigint not null,	# Number of bases in genome
    basesInSpots bigint not null,	# Number of bases in spots
    sumSignal double not null,	# Total signal
    spotSumSignal double not null,	# Total signal in spots
              #Indices
    PRIMARY KEY(id),
    INDEX(wigId),
    INDEX(spotId)
);

#Statistics calculated based on a 5M sample of DNAse aligned reads from a bam file.
CREATE TABLE cdwQaDnaseSingleStats5m (
    id int unsigned auto_increment,	# Id of this row in table.
    fileId int unsigned not null,	# Id of bam file this is calculated from
    sampleReads int unsigned not null,	# Number of mapped reads 
    spotRatio double not null,	# Ratio of signal in spots to total signal,  between 0 and 1
    enrichment double not null,	# Enrichment in spots compared to genome overall
    basesInGenome bigint not null,	# Number of bases in genome
    basesInSpots bigint not null,	# Number of bases in spots
    sumSignal double not null,	# Total signal
    spotSumSignal double not null,	# Total signal in spots
    estFragLength varchar(255) not null,	# Up to three comma separated strand cross-correlation peaks
    corrEstFragLen varchar(255) not null,	# Up to three cross strand correlations at the given peaks
    phantomPeak int not null,	# Read length/phantom peak strand shift
    corrPhantomPeak double not null,	# Correlation value at phantom peak
    argMinCorr int not null,	# strand shift at which cross-correlation is lowest
    minCorr double not null,	# minimum value of cross-correlation
    nsc double not null,	# Normalized strand cross-correlation coefficient (NSC) = corrEstFragLen/minCorr
    rsc double not null,	# Relative strand cross-correlation coefficient (RSC)
    rscQualityTag int not null,	# based on thresholded RSC (codes: -2:veryLow,-1:Low,0:Medium,1:High,2:veryHigh)
              #Indices
    PRIMARY KEY(id),
    INDEX(fileId)
);

#A job to be run asynchronously and not too many all at once.
CREATE TABLE cdwJob (
    id int unsigned auto_increment,	# Job id
    commandLine longblob not null,	# Command line of job
    startTime bigint not null,	# Start time in seconds since 1970
    endTime bigint not null,	# End time in seconds since 1970
    stderr longblob not null,	# The output to stderr of the run - may be nonempty even with success
    returnCode int not null,	# The return code from system command - 0 for success
    pid int not null,	# Process ID for running processes
    submitId int not null,	# Associated submission ID if any
              #Indices
    PRIMARY KEY(id)
);

#Some files can be visualized as a track. Stuff to help define that track goes here.
CREATE TABLE cdwTrackViz (
    id int unsigned auto_increment,	# Id of this row in the table
    fileId int unsigned not null,	# File this is a viz of
    shortLabel varchar(255) not null,	# Up to 17 char label for track
    longLabel varchar(255) not null,	# Up to 100 char label for track
    type varchar(255) not null,	# One of the customTrack types such as bam,vcfTabix,bigWig,bigBed
    bigDataFile varchar(255) not null,	# Where big data file lives relative to cdwRootDir
              #Indices
    PRIMARY KEY(id)
);

#A dataset is a collection of files, usually associated with a paper
CREATE TABLE cdwDataset (
    id int unsigned auto_increment,	# Dataset ID
    name varchar(255) not null,	# Short name of this dataset, one word, no spaces
    label varchar(255) not null,	# short title of the dataset, a few words
    description longblob not null,	# Description of dataset, can be a complete html paragraph.
    pmid varchar(255) not null,	# Pubmed ID of abstract
    pmcid varchar(255) not null,	# PubmedCentral ID of paper full text
    metaDivTags varchar(255) not null,	# Comma separated list of fields used to make tree out of metadata
              #Indices
    PRIMARY KEY(id),
    UNIQUE(name)
);

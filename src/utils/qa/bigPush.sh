#!/bin/bash
set -beEu -o pipefail
source `which qaConfig.bash`
umask 002

################################
#
#  04-15-16
#  Matt Speir
#
#  Designed to make large pushes 
#  of many tables for many assemblies
#  easier.
#
################################


##### Variables #####

dbList=""
tableList=""
verboseMode=""
outputMode=""

##### Functions #####

showHelp() {
cat << EOF
 
Usage: `basename $0` [-hv] \$database(s) \$table(s)

	Required arguments:
	\$database(s)	    A single database or list of databases for which
			    table(s) will be pushed. This list can be a file.
	\$table(s)	    A single table or list of tables to be pushed.
			    List of tables can be a file.

	Optional arguments:
        -h                  Display this help and exit.
	-v VERBOSE MODE	    Output details of push; 1 for results to stdout,
			    2 for results to stdout and file.

Push a table or list of tables from Dev to Beta for a single database or list
of databases.

If you have multiple databases (and/or tables), they can be input in a few
different ways. They can be either in a file or in a space-separated list
enclosed in quotes. For example:

`basename $0` "ce11 hg19 gorGor3" refGene

A list of tables can be pushed in a similar way.

If verbose mode is set, then the output will be sent to stdout.

EOF
}

##### Parse command-line input #####
                       
OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts "hv" opt
do
        case $opt in
                h)
                        showHelp
                        exit 0
                        ;;
                v)
                        verboseMode=true
                        ;;
                '?')
                        showHelp >&2
                        exit 1
                        ;;
        esac           
done                   
               
shift "$((OPTIND-1))" # Shift off the options and optional --.

# Check number of required arguments
if [ $# -ne 2 ]
then
	# Output usage message if number of required arguments is wrong
	showHelp >&2
	exit 1
else
	# Set variables with required argument values
	dbList=$1
	tableList=$2
fi

##### Main Program #####

# Adjust output mode based on specified verbose mode 
if [[ "$verboseMode" == "true" ]]
then
	# Will cause output to be sent to stdout
	outputMode=""
else
	# if no verbose mode specified just send output to /dev/null
	outputMode="> /dev/null"
fi


# First check if dbList is a file.
# If not, skips down to "# Here"
if [[ -e "$dbList" ]]
then
	# Loop through our dbList file
	for db in $(cat "$dbList")
	do
		# Now check if tableList is a file
		if [[ -e "$tableList" ]]
		then
			# If tableList was a file, loop through contents
			for tbl in $(cat "$tableList")
			do
				# Build command with proper database, table name, and output mode.
				command="sudo mypush '$db' '$tbl' mysqlbeta $outputMode"
				# Run command using bash
				echo "$command" | bash
			done
		# Or, if tableList was not a file, push table(s) to beta
		else
			for tbl in $(echo "$tableList")
			do
				command="sudo mypush '$db' '$tbl' mysqlbeta $outputMode"
				echo "$command" | bash
			done
		fi
	done
# Here. 
# Conditional excutes if dbList input was not a file.
else 
	for db in $(echo "$dbList")
	do
		# Similar to above, following conditionals and for loops
		# push tables from dev to beta if dbList was not a file
		if [[ -e "$tableList" ]]
		then
			for tbl in $(cat "$tableList")
			do
				command="sudo mypush '$db' '$tbl' mysqlbeta $outputMode"
				echo "$command" | bash
			done
		else
			for tbl in $(echo "$tableList")
			do
				command="sudo mypush '$db' '$tbl' mysqlbeta $outputMode"
				echo "$command" | bash
			done
		fi
	done
fi

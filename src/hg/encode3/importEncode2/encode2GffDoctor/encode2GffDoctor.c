/* encode2GffDoctor - Fix up gff/gtf files from encode phase 2 a bit.. */
#include "common.h"
#include "linefile.h"
#include "hash.h"
#include "options.h"

void usage()
/* Explain usage and exit. */
{
errAbort(
  "encode2GffDoctor - Fix up gff/gtf files from encode phase 2 a bit.\n"
  "usage:\n"
  "   encode2GffDoctor in.gff out.gff\n"
  "options:\n"
  "   -xxx=XXX\n"
  );
}

/* Command line validation table. */
static struct optionSpec options[] = {
   {NULL, 0},
};

char *replaceFieldInGffGroup(char *in, char *tag, char *newVal)
/* Update value of tag */
{
char *tagStart = stringIn(tag, in);
if (tagStart == NULL)
    internalErr();
char *valEnd = strchr(tagStart, ';');
if (valEnd == NULL)
    internalErr();
struct dyString *dy = dyStringNew(strlen(in));
dyStringAppendN(dy, in, tagStart - in);
dyStringAppend(dy, tag);
dyStringAppendC(dy, ' ');
if (newVal[0] != '"');
    dyStringAppendC(dy, '"');
dyStringPrintf(dy, "%s", newVal);
if (newVal[0] != '"');
    dyStringAppendC(dy, '"');
dyStringAppend(dy, valEnd);
return dyStringCannibalize(&dy);
}

void encode2GffDoctor(char *inFile, char *outFile)
/* encode2GffDoctor - Fix up gff/gtf files from encode phase 2 a bit.. */
{
char *transcriptTag = "transcript_id";
struct lineFile *lf = lineFileOpen(inFile, TRUE);
char *row[9];
FILE *f = mustOpen(outFile, "w");
while (lineFileRowTab(lf, row))
    {
    if (sameString(row[1], "Cufflinks"))
        {
	/* Abbreviate really long transcript IDs. */
	char *trans = stringBetween(transcriptTag, ";", row[8]);
	if (trans != NULL)
	    {
	    char *s = trans;
	    char *id = nextWordRespectingQuotes(&s);
	    int maxSize = 200;
	    if (strlen(id) > maxSize)
	        {
		warn("Abbreviating %s", id);
		id[maxSize-4] = 0;
		char *e = strrchr(id, ',');
		if (e != NULL)
		    {
		    *e++ = '.';
		    *e++ = '.';
		    *e++ = '.';
		    *e++ = '"';
		    *e = 0;
		    }
		warn("Reduced to %s", id);
		row[8] = replaceFieldInGffGroup(row[8], transcriptTag, id);
		}
	    freez(&trans);
	    }
	}
    int i;
    fprintf(f, "%s", row[0]);
    for (i=1; i<9; ++i)
        fprintf(f, "\t%s", row[i]);
    fprintf(f, "\n");
    }
}

int main(int argc, char *argv[])
/* Process command line. */
{
optionInit(&argc, argv, options);
if (argc != 3)
    usage();
encode2GffDoctor(argv[1], argv[2]);
return 0;
}
#!/bin/bash
#Copyright 2021 LliureX
#Licensed under GPL-3.0
##########
# docshell generates an odt from a bunch of markdown files
#########

MD_DIR=/tmp/documents
FORCE_ONLY_MD_EXTENSION=0
ODT_TPL=${PWD}/plantillaDoc.ott
OUTPUT=${HOME}/doc_$(date +%Y%m%d_%H%M).odt
WRKDIR=$(mktemp -d)
WRKFILE=$(tempfile -d $WRKDIR)
ODT_PB="\\newpage"

function debug()
{
    [ ! -z $DEBUG ] && echo "$(date +%Y%m%d_%H%M): $1"
}

function uncompress()
{
    OLD=$PWD
    BASENAME=$(basename ${1/.*/})
    cd $MD_DIR
    mkdir $BASENAME
    cd $BASENAME
    case $2 in
        "tar")
            tar -xvf ../$1
            ;;
        "zip")
            unzip x ../$1
            ;;
        "gzip")
            gzip -d ../$1
            ;;
    esac
    mkdir $WRKDIR/Pictures
    cp Pictures/* $WRKDIR/Pictures
    cd $OLD
    process_md_file ${BASENAME}/${BASENAME}.md 
}

function process_md_file()
{
    debug "Adding ${MD_DIR}/$1"
    #It will be easy with a pandoc filter but for testing purposes...
    #Deletes numbered index from section headers
    sed  's/^1. *\(.*\[\]{#anchor}*\)/\\newpage\n\0/g' ${MD_DIR}/${1} >> $WRKFILE
    echo $ODT_PB >> $WRKFILE
    echo "" >> $WRKFILE
}

function process_file()
{
    debug "Checking ${MD_DIR}/$1"
    TYPE=$(file -b --mime-type ${MD_DIR}/$1)
    case $TYPE in
        "application/x-tar")
            uncompress $1 "tar"
            ;;
        "application/zip")
            uncompress $1 "zip"
            ;;
        "application/gzip")
            uncompress $1 "gzip"
            ;;
        "text/plain")
            process_md_file $1
            ;;
    esac
}

process_wrkfile()
{
    #md->latex->odt
    [ -z $DEBUG ] || VERBOSE="--verbose"
    #First step, convert markdown to latex
    CMD="pandoc $VERBOSE ${WRKFILE} -f markdown -t latex -s -o $WRKFILE.tex  --metadata lang=es-ES"
    debug "$CMD"
    eval $CMD
    #2n: Fix formats for odt
    sed -i '/^\\def\\labelenumi{\\arabic{enumi}.}$/d' ${WRKFILE}.tex
    awk -i inplace 'BEGIN {printcontrol=0 }; {if ( $0=="\\begin{document}") {print $0;printcontrol=2}; if ($0=="\\newpage") {printcontrol=0};if ($0=="\\begin{enumerate}" || $0=="\\end{enumerate}")  printcontrol=1; if ( printcontrol==0 ){ print $0};if (printcontrol!=2) {printcontrol=0}}' ${WRKFILE}.tex
    #Last: Generate odt with associated template
    CMD="pandoc $VERBOSE  -f latex -t odt -o $OUTPUT ${WRKFILE}.tex --reference-doc=$ODT_TPL --top-level-division=section --resource-path=$WRKDIR --toc"
    debug "$CMD"
    eval $CMD
    debug "Generated ${WRKFILE}.tex"
}

function process_md_dir(){
    for md in $(ls -1 $MD_DIR)
    do
        #Force only .md files. don't enable, testing purposes.
        if [ $FORCE_ONLY_MD_EXTENSION -ne 0 ]
        then
            [[ ${md//*.md/1} == 1 ]] && process_file $md
        else
            process_file $md
        fi
    done
    debug "MD file generated as $WRKFILE"
    process_wrkfile
    rm -fr $WRKDIR
}

function show_help()
{
    echo "Usage: ./docshell.sh OPTIONS"
    echo "Generates an .odt file from markdown files (compressed) present at specified dir."
    echo ""
    echo "Options:"
    echo " -t --template: odt template (default $ODT_TPL)"
    echo " -f --force: Process only md files in directory (default process all)"
    echo " -d --md-directory: Directory with markdown files to process (default $MD_DIR)"
    echo " -o --output: Output file (default $OUTPUT)"
    echo " --debug: Debug mode"
    echo ""
    exit 0
}

function process_args()
{
    while [[ $# -gt 0 ]]
    do
        case $1 in
            -t|--template)
                ODT_TPL=$2
                shift
                ;;
            -f|--force)
                FORCE_ONLY_MD_EXTENSION=1
                ;;
            -d|--md-directory)
                MD_DIR=$2
                ;;
            -o|--output)
                OUTPUT=$2
                shift
                ;;
            --debug)
                DEBUG=1
                ;;
            *)
                show_help
                ;;
        esac
        shift
    done
}

if [[  "x$@" != 'x' ]]
then
    process_args $@
fi

process_md_dir 
printf "\n********\nGenerated $OUTPUT\n"
exit 0

# lliurex-documentator
Shell script that generates internal documentation from partial documents.

Usage: ./docshell.sh OPTIONS

Generates an .odt file from markdown files (compressed) availables at specified dir.

Options:

 -t --template: odt template (default ./plantillaDoc.ott)

 -n --no-force: Process all files in directory (default process only *,md)

 -d --md-directory: Directory with markdown files to process (default /tmp/documents)
 
 -o --output: Output file (default /home/lliurex/doc_YYYYMMDD_HHmm.odt)
 
 --debug: Debug mode

==================================================================

All files must be compressed (tar, gzip or zip) with this structure:

 - text.md
 - Pictures/
 - Pictures/*
 
 
Because LibreOffice implementation the index of the odt file must be manually updated when file is generated.
The cover of the document is not included (WIP)

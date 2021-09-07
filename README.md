# lliurex-documentator
Shell script that generates internal documentation from partial documents.

Usage: ./docshell.sh OPTIONS
Generates an .odt file from markdown files (compressed) present at specified dir.

Options:
 -t --template: odt template (default /home/lliurex/git/docshell/plantillaDoc.ott)
 -n --no-force: Process all files in directory (default process only *,md)
 -d --md-directory: Directory with markdown files to process (default /tmp/documents)
 -o --output: Output file (default /home/lliurex/doc_20210907_1128.odt)
 --debug: Debug mode


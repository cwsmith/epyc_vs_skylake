Peak memory usage of the 48 process run with up to 30M dofs was recorded using
top in batch mode during an interactive session in the skx-dev partition.
The following `awk` command was used to extract the peak usage:

`awk '/KiB mem/ {print $6}' mem.log | sort -n`


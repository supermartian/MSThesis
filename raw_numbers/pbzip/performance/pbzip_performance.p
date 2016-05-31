set terminal postscript eps noenhanced color font 'Helvetica,16'
set style fill solid
set boxwidth 0.2
set xlabel "Thread Count"
set ylabel "Compression Time (seconds)"

set output 'pbzip2_b10.eps'
set title "pbzip2 compresses 177MB file"
plot 'pbzip_b10.csv' u ($0-0.2):2 t "Linux" with boxes, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with boxes, \
     '' u ($0+0.2):4 t "Schedule Replication" with boxes

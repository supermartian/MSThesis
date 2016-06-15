set terminal png font 'Helvetica,12' size 800, 600
set style fill solid
set xlabel "Thread Count"
set ylabel "Compression Time (seconds)"

set output 'pbzip2_b10.png'
set title "pbzip2 compresses 177MB file"
plot 'pbzip_b10.csv' u 2:xticlabels(1) t "Linux" with linespoints ls 1 lw 3, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with linespoints ls 2 lw 3, \
     '' u 4:xticlabels(1) t "Schedule Replication" with linespoints ls 3 lw 3

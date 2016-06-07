set terminal postscript eps noenhanced color font 'Helvetica,16'
set style fill solid
set boxwidth 0.2
set xlabel "File Size (KB)"
set ylabel "Through Put (KB/s)"
set format y "%10.0f"
set yrange [60000:140000]

set output 'mg_throughput_4t.eps'
set title "Mongoose 4 thread messages"
plot 'mg_linux_4.csv' u ($0-0.2):2 t "Linux" with boxes, \
     'mg_pcn_det_4.csv' u 2:xticlabels(1) t "Deterministic Execution" with boxes, \
     'mg_pcn_rep_4.csv' u ($0+0.2):2 t "Schedule Replication" with boxes

set output 'mg_throughput_8t.eps'
set title "Mongoose 8 thread messages"
plot 'mg_linux_8.csv' u ($0-0.2):2 t "Linux" with boxes, \
     'mg_pcn_det_8.csv' u 2:xticlabels(1) t "Deterministic Execution" with boxes, \
     'mg_pcn_rep_8.csv' u ($0+0.2):2 t "Schedule Replication" with boxes

set output 'mg_throughput_16t.eps'
set title "Mongoose 16 thread messages"
plot 'mg_linux_16.csv' u ($0-0.2):2 t "Linux" with boxes, \
     'mg_pcn_det_16.csv' u 2:xticlabels(1) t "Deterministic Execution" with boxes, \
     'mg_pcn_rep_16.csv' u ($0+0.2):2 t "Schedule Replication" with boxes

set output 'mg_throughput_200k.eps'
set title "Mongoose Servering 200KB file"
plot 'mg_200k.csv' u 2:xticlabels(1) t "Linux" with linespoints ls 1 lw 3, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with linespoints ls 2 lw 3, \
     '' u 4:xticlabels(1) t "Schedule Replication" with linespoints ls 3 lw 3

set output 'mg_throughput_100k.eps'
set title "Mongoose Servering 100KB file"
plot 'mg_100k.csv' u 2:xticlabels(1) t "Linux" with linespoints ls 1 lw 3, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with linespoints ls 2 lw 3, \
     '' u 4:xticlabels(1) t "Schedule Replication" with linespoints ls 3 lw 3

set output 'mg_throughput_50k.eps'
set title "Mongoose Servering 50KB file"
plot 'mg_50k.csv' u 2:xticlabels(1) t "Linux" with linespoints ls 1 lw 3, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with linespoints ls 2 lw 3, \
     '' u 4:xticlabels(1) t "Schedule Replication" with linespoints ls 3 lw 3

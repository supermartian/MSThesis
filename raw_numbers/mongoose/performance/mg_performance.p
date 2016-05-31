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

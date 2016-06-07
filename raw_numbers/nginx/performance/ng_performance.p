set terminal postscript eps noenhanced color font 'Helvetica,16'
set style fill solid
set boxwidth 0.2
set xlabel "Thread count"
set ylabel "Throughput (KB/s)"
set format y "%10.0f"
set yrange[60000:130000]

set output 'ng_throughput_200k.eps'
set title "Nginx Servering 200KB file"
plot 'nginx_200k.csv' u 2:xticlabels(1) t "Linux" with linespoints ls 1 lw 3, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with linespoints ls 2 lw 3, \
     '' u 4:xticlabels(1) t "Schedule Replication" with linespoints ls 3 lw 3

set output 'ng_throughput_100k.eps'
set title "Nginx Servering 100KB file"
plot 'nginx_100k.csv' u 2:xticlabels(1) t "Linux" with linespoints ls 1 lw 3, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with linespoints ls 2 lw 3, \
     '' u 4:xticlabels(1) t "Schedule Replication" with linespoints ls 3 lw 3

set output 'ng_throughput_50k.eps'
set title "Nginx Servering 50KB file"
plot 'nginx_50k.csv' u 2:xticlabels(1) t "Linux" with linespoints ls 1 lw 3, \
     '' u 3:xticlabels(1) t "Deterministic Execution" with linespoints ls 2 lw 3, \
     '' u 4:xticlabels(1) t "Schedule Replication" with linespoints ls 3 lw 3

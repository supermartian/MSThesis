set terminal postscript eps noenhanced color font 'Helvetica,15'
set output 'redis_2.eps'
set ylabel "req/s"
set xlabel "operation"
set boxwidth 0.2
set style fill solid
set xtics nomirror rotate by -45
set title "redis benchmark 2 clients (higher  better)"
set yrange[0:27000]

plot "redis_c2.csv" u ($0-0.25):4:xtic(1) title "Linux" with boxes, \
     "redis_c2.csv" u 0:3 title "Deterministic Execution" with boxes, \
     "redis_c2.csv" u ($0+0.25):2 title "Schedule Replication" with boxes

set title "redis benchmark 16 clients (higher the better)"
set output 'redis_16.eps'
set yrange[0:47000]
plot "redis_c16.csv" u ($0-0.25):4:xtic(1) title "Linux" with boxes, \
     "redis_c16.csv" u 0:3 title "Deterministic Execution" with boxes, \
     "redis_c16.csv" u ($0+0.25):2 title "Schedule Replication" with boxes

set title "redis benchmark 64 clients (higher the better)"
set output 'redis_64.eps'
set yrange[0:50000]
plot "redis_c64.csv" u ($0-0.25):4:xtic(1) title "Linux" with boxes, \
     "redis_c64.csv" u 0:3 title "Deterministic Execution" with boxes, \
     "redis_c64.csv" u ($0+0.25):2 title "Schedule Replication" with boxes

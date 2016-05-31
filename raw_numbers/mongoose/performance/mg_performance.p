set terminal postscript eps noenhanced color font 'Helvetica,16' size 7, 4
set boxwidth 0.4
set style fill solid
set xlabel "Thread count"
set ylabel "Through Put (KB/s)"
set format y "%10.0f"

set output 'mg_throughput_50k.eps'
set title "Mongoose 4 thread messages"

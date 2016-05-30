set terminal postscript eps noenhanced color font 'Helvetica,15'
set style data histogram
set style histogram rowstack gap 1
set boxwidth 0.5
set style fill solid
set xlabel "File Size"
set ylabel "% of total messages"
set format y "%10.0f"

set yrange [:6000000]
set output 'mg_msg_4.eps'
set title "Mongoose 4 thread messages"
plot 'mg_pcn_rep_msg_4.csv' using 3:xtic(1) t 'Schedule Messages', '' u 4 t 'Syscall Messages', '' u 5 t 'Network Messages'

set yrange [:8000000]
set output 'mg_msg_8.eps'
set title "Mongoose 8 thread messages"
plot 'mg_pcn_rep_msg_8.csv' using 3:xtic(1) t 'Schedule Messages', '' u 4 t 'Syscall Messages', '' u 5 t 'Network Messages'

set output 'mg_msg_16.eps'
set title "Mongoose 16 thread messages"
plot 'mg_pcn_rep_msg_16.csv' using 3:xtic(1) t 'Schedule Messages', '' u 4 t 'Syscall Messages', '' u 5 t 'Network Messages'

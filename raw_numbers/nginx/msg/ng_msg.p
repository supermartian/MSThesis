set terminal postscript eps noenhanced color font 'Helvetica,16' size 7, 4
set style data histogram
set style histogram rowstack gap 1 title offset 0,-1
set boxwidth 0.4
set style fill solid
set ylabel "Number of Messages"
set format y "%10.0f"
set yrange [0:5000000]
set bmargin 5

set output 'ng_msg_50k.eps'
set title "Nginx Messages for Servering 50KB"
plot newhistogram "4 Threads", \
    "<(sed -n '1,2p' ng_pcn_msg_t4.csv)" u 4:xticlabels(1) title 'Schedule Messages' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title 'Syscall Messages' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title 'Network Messages' linecolor rgb "blue", \
    newhistogram "8 Threads", \
    "<(sed -n '1,2p' ng_pcn_msg_t8.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "16 Threads", \
    "<(sed -n '1,2p' ng_pcn_msg_t16.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue",

set output 'ng_msg_100KB.eps'
set title "Nginx Messages for Servering 100KB"
plot newhistogram "4 Threads", \
    "<(sed -n '3,4p' ng_pcn_msg_t4.csv)" u 4:xticlabels(1) title 'Schedule Messages' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title 'Syscall Messages' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title 'Network Messages' linecolor rgb "blue", \
    newhistogram "8 Threads", \
    "<(sed -n '3,4p' ng_pcn_msg_t8.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "16 Threads", \
    "<(sed -n '3,4p' ng_pcn_msg_t16.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue"
set output 'ng_msg_200KB.eps'
set title "Nginx Messages for Servering 200KB"
plot newhistogram "4 Threads", \
    "<(sed -n '5,6p' ng_pcn_msg_t4.csv)" u 4:xticlabels(1) title 'Schedule Messages' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title 'Syscall Messages' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title 'Network Messages' linecolor rgb "blue", \
    newhistogram "8 Threads", \
    "<(sed -n '5,6p' ng_pcn_msg_t8.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "16 Threads", \
    "<(sed -n '5,6p' ng_pcn_msg_t16.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue"

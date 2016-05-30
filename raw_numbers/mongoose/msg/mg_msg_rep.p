set terminal postscript eps noenhanced color font 'Helvetica,15' size 7, 4
set style data histogram
set style histogram rowstack gap 0.5 title offset 0,-1
set boxwidth 0.4
set style fill solid
set xlabel "File Size"
set ylabel "Number of Messages"
set format y "%10.0f"
set yrange [:8000000]

set output 'mg_msg_4.eps'
set title "Mongoose 4 thread messages"
plot newhistogram "50k", \
    "<(sed -n '1,2p' mg_pcn_msg_t4.csv)" u 4:xticlabels(1) title 'Schedule Messages' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title 'Syscall Messages' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title 'Network Messages' linecolor rgb "blue", \
    newhistogram "100k", \
    "<(sed -n '3,4p' mg_pcn_msg_t4.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "200k", \
    "<(sed -n '5,6p' mg_pcn_msg_t4.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "400k", \
    "<(sed -n '7,8p' mg_pcn_msg_t4.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue"

set output 'mg_msg_8.eps'
set title "Mongoose 8 thread messages"
plot newhistogram "50k", \
    "<(sed -n '1,2p' mg_pcn_msg_t8.csv)" u 4:xticlabels(1) title 'Schedule Messages' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title 'Syscall Messages' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title 'Network Messages' linecolor rgb "blue", \
    newhistogram "100k", \
    "<(sed -n '3,4p' mg_pcn_msg_t8.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "200k", \
    "<(sed -n '5,6p' mg_pcn_msg_t8.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "400k", \
    "<(sed -n '7,8p' mg_pcn_msg_t8.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue"

set output 'mg_msg_16.eps'
set title "Mongoose 16 thread messages"
plot newhistogram "50k", \
    "<(sed -n '1,2p' mg_pcn_msg_t16.csv)" u 4:xticlabels(1) title 'Schedule Messages' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title 'Syscall Messages' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title 'Network Messages' linecolor rgb "blue", \
    newhistogram "100k", \
    "<(sed -n '3,4p' mg_pcn_msg_t16.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "200k", \
    "<(sed -n '5,6p' mg_pcn_msg_t16.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue", \
    newhistogram "400k", \
    "<(sed -n '7,8p' mg_pcn_msg_t16.csv)" u 4:xticlabels(1) title '' linecolor rgb "red", \
    ''                               u 5:xticlabels(1) title '' linecolor rgb "green", \
    ''                               u 6:xticlabels(1) title '' linecolor rgb "blue"

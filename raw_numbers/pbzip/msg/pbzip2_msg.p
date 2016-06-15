set terminal png font 'Helvetica,12' size 800, 600
set style data histogram
set style histogram rowstacked title offset 0,-4
set boxwidth 0.4
set style fill solid
set ylabel "Number of Messages"
set yrange[0:8000]
set bmargin 6
set xtics rotate by 45 offset 0,-3.3

set output 'pbzip2_msg.png'
set title "pbzip2 Messages"
plot newhistogram "2 threads", \
    "<(sed -n '1,2p' pbzip2_pcn_msg.csv)" u 3:xticlabels(1) title 'Schedule Messages' linecolor rgb "red", \
                      ""  u 4:xticlabels(1) title 'Syscall Messages' linecolor rgb "green", \
     newhistogram "4 threads", \
    "<(sed -n '3,4p' pbzip2_pcn_msg.csv)" u 3:xticlabels(1) title '' linecolor rgb "red", \
                      ""  u 4:xticlabels(1) title '' linecolor rgb "green", \
     newhistogram "8 threads", \
    "<(sed -n '5,6p' pbzip2_pcn_msg.csv)" u 3:xticlabels(1) title '' linecolor rgb "red", \
                      ""  u 4:xticlabels(1) title '' linecolor rgb "green", \
     newhistogram "16 threads", \
    "<(sed -n '7,8p' pbzip2_pcn_msg.csv)" u 3:xticlabels(1) title '' linecolor rgb "red", \
                      ""  u 4:xticlabels(1) title '' linecolor rgb "green", \
     newhistogram "24 threads", \
    "<(sed -n '9,10p' pbzip2_pcn_msg.csv)" u 3:xticlabels(1) title '' linecolor rgb "red", \
                      ""  u 4:xticlabels(1) title '' linecolor rgb "green", \

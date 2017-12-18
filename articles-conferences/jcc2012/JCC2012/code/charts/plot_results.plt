reset
set terminal pdf
set output "results.pdf"
set datafile separator ","
set key autotitle columnhead
set xlabel "Time"
set ylabel "Error"
set style line 1 lt -1 lw 1 pt 5 ps 0.5
set style line 2 lt -1 lw 1 pt 9 ps 0.5
set style line 3 lt -1 lw 1 pt 2 ps 0.5
set style line 4 lt -1 lw 3
#plot for [i=1:4] "results.csv" using i with linespoints ls i
#pause -1 "Hit any key to continue"

plot "results.csv" using 3 with linespoints ls 3,\
"" using 4 with lines ls 4



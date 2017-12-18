reset
set terminal pdf
set output "data.pdf"
set datafile separator ","
set key autotitle columnhead
set xlabel "Time"
set ylabel "Price"
plot for [i=1:9] "data_2000.csv" using i with lines
pause -1 "Hit any key to continue"

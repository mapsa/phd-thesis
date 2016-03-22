import classes as cl
import numpy as np
import time
import sys
from statsmodels.tsa.stattools import adfuller

try:
    from line_profiler import LineProfiler

    def do_profile(follow=[]):
        def inner(func):
            def profiled_func(*args, **kwargs):
                try:
                    profiler = LineProfiler()
                    profiler.add_function(func)
                    for f in follow:
                        profiler.add_function(f)
                    profiler.enable_by_count()
                    return func(*args, **kwargs)
                finally:
                    profiler.print_stats()
            return profiled_func
        return inner

except ImportError:
    def do_profile(follow=[]):
        "Helpful if you accidentally leave in production!"
        def inner(func):
            def nothing(*args, **kwargs):
                return func(*args, **kwargs)
            return nothing
        return inner


def SLECM(y, L, P):
    # SLECM Test
    m = cl.Matrix()
    it = y.shape[0] - L

    for i in range(it):
        y_i = y[i:i + L]
        beta = m.get_johansen(y_i.as_matrix(), P)

        A, B, beta = m.vec_matrix(y_i, P, beta.evecr)
        x, residuals, rank, s = np.linalg.lstsq(A, B)


def SLAAR_1(y, L, P, update):
    # SLAAR Test
    m = cl.Matrix()
    #it = y.shape[0] - L
    it = 100

    for i in range(it):
        sys.stdout.write("\r{0}%".format((float(i + 1) / it) * 100))
        sys.stdout.flush()

        y_i = y[i:i + L]

        if(i % update == 0):
            beta = m.get_johansen(y_i.as_matrix(), P)
            A, B = m.vec_matrix(y_i, P, beta.evecr)
            #lambda_svd = m.lambda_svd(A, np.linalg.matrix_rank(A))
            lambda_qr = m.lambda_qr(A)
        else:
            A, B = m.vec_matrix(y_i, P, beta.evecr)
            pass

        #x = m.iteration(A, B, 3, 2, lambda_svd, 0.00025)
        x, residuals, rank, s = np.linalg.lstsq(A, B)
        x = m.iteration(A, B, 3, 2, lambda_qr)


def SLAAR_2(y, L, P, it, avg_error, r, n):
    # SLAAR Using MAPE
    it2, l = y.shape
    #it = 100                            # Number of iterations
    #r = 1                               # Number of cointegration relations
    #n = 10                              # Number of instances to calculate MAPE
    new_beta = False
    #avg_error = 120

    Y_true = np.zeros([it, l])          # Out of sample 
    Y_pred = np.zeros([it, l])          # Forecasting
    mape = np.zeros([it, l])            # In-sample mape

    m = cl.Matrix()
    start_time = time.time()
    for i in range(it):
        sys.stdout.write("\r{0}%".format((float(i + 1) / it) * 100))
        sys.stdout.flush()
        y_i = y[i:i + L]

        if i == 0:
            beta = m.get_johansen(y_i.as_matrix(), P, r)
            A, B = m.vec_matrix(y_i, P, beta.evecr)
        else:
            A, B = m.vec_matrix_online(A, B, y_i, P, beta.evecr)
            Y_true[i,:] = B[-1,:]
            Y_pred[i,:] = np.dot(A[-1,:], x)
            
        x, residuals, rank, s = np.linalg.lstsq(A, B)
        Ax = np.dot(A, x)
        residuals = B - Ax
        
        y_true = B[-n:]
        y_pred = Ax[-n:]
       
        mape[i,:] = m.MAPE(y_true, y_pred)
        try:
            avg_mape = np.average(mape[i,:])
        except:
            print i,i+L

        if avg_mape > avg_error:
            try:
                beta = m.get_johansen(y_i.as_matrix(), P)
            except:
                print "Unexpected error"
                print i, i+ L

            r = beta.r
            A = m.vec_matrix_update(A, y_i, P, beta.evecr)
            x, residuals, rank, s = np.linalg.lstsq(A, B)     
    
    # Out-of-Sample MAPE
    o_mape = m.MAPE(Y_true, Y_pred)     
    return y_true, y_pred, Y_true, Y_pred, mape, o_mape, time.time() - start_time

#@do_profile(follow=[SLECM, SLAAR_1, SLAAR_2])
@do_profile(follow=[SLAAR_1])

def tests(data):
    m = cl.Matrix()
    y=np.log(data)                 # Logarithm of currencie
    r = 0
    Ls = [300, 3000]
    Ps = [4, 8]
    its = [10000]
    ns = [100]
    avg_errors = [0, 110, 120]
    f = open('tests.csv', 'a')
    f.write('r,L,P,it,n,avg_error,ttime,avgtime,MAPE EURUSD,MAPE GBPUSD, MAPE CHFUSD, MAPE JPYUSD \n')
    f.close()
    for L in Ls:
        for P in Ps:
            for it in its:
                #llamar a SLECM
                # imprimir a archivo
                for n in ns:
                    for avg_error in avg_errors:
                        print "running for: L: ", L," P: ", P, " it: ", it, " n: ", n, " avg_error: ", avg_error 
                        y_true, y_pred, Y_true, Y_pred, mape, o_mape, etime = SLAAR_2(y,L,P,it,avg_error,r,n)
                        f = open('tests.csv', 'a')
                        f.write(str(r)+','+str(L)+','+str(P)+','+str(it)+','\
                                +str(n)+','+str(avg_error)+','+str(etime)+','+str(etime/it)+","+','.join(map(str, o_mape))+"\n")
                        f.close()
    
def main():
    L = 3000                                            # Length of window
    P = 4                                               # Number of lags
    update = 5                                          # Update

    tickers = ['EURUSD', 'GBPUSD','CHFUSD','JPYUSD']    # Currencies list

    print "Reading data ..."
    reader = cl.Reader('../data_csv/data_ask.csv')
    data = reader.load_data(tickers)

    # SLECM(y, L, P)
    #SLAAR_1(y, L, P, update)
    #print "Calculating SLAAR_2"
    #SLAAR_2(y, L, P)
    tests(data)

def synthetic_main():

    tickers = ['col1', 'col2','col3','col4']  
    print "Reading data ..."
    reader = cl.Reader('../data_csv/synthetic-data.csv')
    data = reader.load_data(tickers)
    data = data - data.min()  # Avoiding negative numbers


    y=np.log(data)                 # Logarithm of currencies
    L = 3000                    # Length of window
    P = 4                       # Number of lags
    it, l = y.shape
    it = it - L
    it = 100
    it = 10000
    r = 1                       # Number of cointegration relations, if 0 get Johansen r
    n = 50                      # Number of instances to calculate MAPE
    avg_error = 0             # MAPE threshold to get new beta
    y_true, y_pred, Y_true, Y_pred, mape, o_mape, etime = SLAAR_2(y,L,P,it,avg_error,r,n)
    print "elapsed time: ", etime 
    print "Out-of-sample MAPE", o_mape


if __name__ == "__main__":
    #main()
    synthetic_main()

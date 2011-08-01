import numpy as np
from numpy import linalg as la
import pylab as pb
from scipy import kron
from scipy.special import erfc
from scipy.linalg import toeplitz, inv, pinv, norm
from scipy.sparse import rand as sp
from l1regls import l1regls
from cvxopt import matrix as cvxmatrix
from multiprocessing import Pool


class SYSTEM:
    def __init__(self, N, K, D, SNR):
        self.N = N
        self.K = K
        self.D = D
        self.A = np.matrix(np.random.randn(K,N)/np.sqrt(N))
        self.X = 10*sp(N,1,density=D/N).todense()
        self.Y = self.A * self.X
        self.SNR = SNR
        snr = 10**(-self.SNR/10.0)
        eng = norm(self.Y)/np.sqrt(K)
        self.V = np.matrix(eng*snr*np.random.randn(K,1))
        self.Y = self.Y + self.V

    def mp(self):
        RF = self.Y
        the = norm(RF)/self.N
        n = 1
        self.MPXX = np.zeros_like(self.X)
        while norm(RF) > the:
            id = np.argmax(RF.T*self.A)
            g = self.A[:,id]
            a = RF.T*g
            self.MPXX[id] = self.MPXX[id] + a
            RF = RF - np.multiply(a,g)
            n = n + 1
            if n>self.N:
                break
        self.MPerr = norm(self.MPXX-self.X,2)/norm(self.X,2)

    def LS(self):
        self.LSXX = pinv(self.A) * self.Y
        self.LSerr = norm(self.LSXX-self.X, 2)/norm(self.X,2)
    
    def L1(self):
        A = cvxmatrix(self.A)
        Y = cvxmatrix(self.Y)
        X = cvxmatrix(self.X)
        self.L1XX = l1regls(A, Y)
        self.L1err = norm(self.L1XX-X, 2)/norm(self.X,2)

    def draw(self):
        N = np.arange(self.N)
        pb.grid(True)
        X = np.asarray(self.X)
        pb.scatter(N, X, s=40, c='b', marker = '+', label='Real')
        X = np.asarray(self.LSXX)
        pb.scatter(N, X, s=40, c='g', marker = 's', label='LS')
        X = np.asarray(self.L1XX)
        pb.scatter(N, X, s=40, c='r', marker = 'o',label='L1')
        #X = np.asarray(self.MPXX)
        #pb.scatter(N, X, s=40, c='m', marker = 'v',label='MP')
        pb.legend()

    def debug(self):
        #print self.A
        print self.X
        print self.LSXX
        print self.L1XX
        print self.MPXX
        print self.LSerr
        print self.L1err
        print self.MPerr

N = 128
K = 512
D = 20.0
SNR = np.linspace(-10,20,20)
err1 = []
err2 = []
err3 = []
test = SYSTEM(N=N,K=K, D=D, SNR=10)
test.LS()
test.L1()
test.mp()
test.debug()
test.draw()
pb.show()

for snr in SNR:
    LSE = []
    L1E = []
    MPE = []
    for i in range(100):
        test = SYSTEM(N=N,K=K, D=D, SNR=snr)
        test.LS()
        test.L1()
        #test.mp()
        LSE.append(test.LSerr)
        L1E.append(test.L1err) 
        #MPE.append(test.MPerr) 
    err1.append(np.mean(LSE))
    err2.append(np.mean(L1E))
    #err3.append(np.mean(MPE))
pb.semilogy(SNR, err1, '+',label='LS')
pb.semilogy(SNR, err2, 'o',label='L1')
#pb.semilogy(SNR, err3, '*',label='MP')
pb.grid(True)
pb.legend()
pb.show()



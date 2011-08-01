clear all;
clc;
N = 9;  

row_C = sparse([1;zeros(N-1,1)]);
row_R = sparse([1, zeros(1,(N-1))]);
row = toeplitz(row_C, row_R);
ROW = sparse( kron(row, kron(ones(1,N), speye(N))) );

col_R = sparse(kron(ones(1,N), [1 zeros(1,N-1)]));
col = toeplitz(row_C, col_R);
COL = sparse( kron(col, speye(N)) );

box_R = kron(ones(1,sqrt(N)), [1 zeros(1, N/sqrt(N)-1)]);
box = toeplitz([1;zeros(sqrt(N)-1,1)], box_R);
box = sparse( kron(speye(sqrt(N)), box) );
BOX = sparse( kron(box, [speye(N) speye(N) speye(N)]));

cell = speye(N^2);
CELL = sparse( kron(cell, ones(1,N)) );

question = [
    5,3,0,  0,7,0,  0,0,0;
    6,0,0,  1,9,5,  0,0,0;
    0,9,8,  0,0,0,  0,6,0;

    8,0,0,  0,6,0,  0,0,3;
    4,0,0,  8,0,3,  0,0,1;
    7,0,0,  0,2,0,  0,0,6;

    0,6,0,  0,0,0,  2,8,0;
    0,0,0,  4,1,9,  0,0,5;
    0,0,0,  0,8,0,  0,7,9;
]
[r,c,v] = find(question'); 
table = ( (c-1)*N + r -1 )';
table = [table; v'];
CLUE = [];
for i = 1:size(table')
    clue = sparse(1,N^3);
    clue(table(1,i)*N + table(2,i)) = 1;
    CLUE = [CLUE;clue];
end

A = [ROW;COL;BOX;CELL;CLUE];
[m,n] = size(A);
b = ones(m,1);

cvx_begin
    variable x(n);
    minimize (norm(x,1));
    subject to
        A*x == b;
cvx_end

x = (x>0.5);
X = reshape(x,N,N^2);
[r, c] = find(X);
solution = reshape(r,N,N);
solution'

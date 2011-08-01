clear all;
N = 9;  # Sukudo length
X = sparse(N^3,1);

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

CLUE = sparse(1,N^3);
CLUE(1*N + 1) = 1;

A = [ROW;COL;BOX;CELL;CLUE];
[m,n] = size(A);
b = ones(m,1);


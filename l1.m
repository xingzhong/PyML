function xx = l1(A, B)
    [m,n] = size(A);
    cvx_begin
        variable x(n);
        minimize (norm(x,1));
        subject to
            A*x == B;
    cvx_end
    xx = x;

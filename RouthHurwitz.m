function[] = RouthHurwitz()
% RouthHurwitz()
% Versión para Matlab 2024b
% Esta función recibe como entrada una función de transferencia en lazo cerrado y proporciona la tabla de Routh conjuntamente con el análisis de estabilidad del sistema.
% La solución funciona también para los casos donde: (1) el primer elemento de la fila es cero; (b) se tiene una fila de ceros.
%
% Acepta funciones de transferencia con la variable desconocida K, dando como resultado la tabla de Routh y el rango de K que hace al sistema estable.
% Ejemplos:
% 1. 1000/((s+2)*(s+3)*(s+5))
% 2. 10/(s^5+2*s^4+3*s^3+6*s^2+5*s-7)
% 3. 10/(s^5+7*s^4+6*s^3+42*s^2+8*s+46)
% 4. 20/(s^8+s^7+12*s^6+22*s^5+39*s^4+59*s^3+48*s^2+38*s)
% 5. K/(s*(s+7)*(s+11))
%
% (c) Reynaldo Vladimir Hurtado Morato 2006
% Universidad Mayor de San Andres, La Paz, Bolivia
% E-mail: reyhur@gmail.com
%declara variables simbolicas
K = sym("K");
s = sym("s");
%ingresa funcion de transferencia en lazo abierto: K/((s+1)*(s+2)*(s+3) ; s^3+2*s^2+5*s+6
G = sym(input("Funcion de Transferencia: "));
fprintf('\nLazo abierto\n');
G
[n,d]=numden(G);
%transforma a lazo cerrado
chareq = sym(d+n);
fprintf('\nLazo cerrado\n');
T = n/chareq
%simplify(chareq)
%invoca al método principal
calculoRouthHurwitz(chareq);
function[] = calculoRouthHurwitz(chareq)
    s = sym("s");
    cheq = simplify(chareq);
    %obtiene numerado y denominador de la función de transferencia
    [n,d]=numden(1/simplify(1/cheq)); %[d, n] = numden(simplify(1/cheq));
    %verifica si el numerador es nulo
    cheq = n == 0;
    cheq = collect(n,s) == 0;
    %forma las dos primeras filas de la tabla de Routh-Hurwitz
    %%R = sym2poly(n);
    R = coeffs(n, s);
    [f,c]=size(R);
    ii = 0;
    RT1 = [];
    RT2 = [];
    for i = 1:2:c
        RT1 = [RT1 R(1,i)];
    end
    for j = 2:2:c
        RT2 = [RT2 R(1,j)];
    end
    if c ~= 2*round(c/2)
        RT2 =[RT2 0];
    end
    RT = [RT1 ; RT2];
    [f1,c1]=size(RT);
    %verificar si la fila de ceros
    filacero = detectafilacero(RT(2,:));
    %si la fila es de ceros ejecuta el procedimiento cuando una fila es cero
    if filacero == true
        ii = 1;
        [RT(2,:), pols] = procfilacero(RT(1,:),c-1);
    end
    %matriz sobre la que se ejecuta el pivote
    A = RT;
    flagsim = false;
    %%if nnz(has(RT,K)) ~= 0
    if class(K)~="sym"
        flagsim = true;
    end
    %genera tabla de Routh-Hurwitz
    [F, pols, jj, flagcero] = proctabla(A, c, flagsim);
    if ii == 0
        ii = jj;
    end
    [cambiosigno1, cambiosigno2] = analisis(F, pols, ii);
    c=c-1;
    positivas = cambiosigno1 + cambiosigno2;
    imaginarias = 0;
    if ii > 0
        imaginarias = 2*round((c-ii-cambiosigno2-0.5)/2);
    end
    negativas = c-positivas-imaginarias;
    total = positivas + negativas + imaginarias;
    if flagcero > 0
        fprintf('\n Tabla Routh-Hurwitz para e = 0.1 en fila %d :\n', flagcero+1);
    else
        fprintf('\n Tabla Rout-Hurwitz :\n');
    end
F
    if flagsim == false
        fprintf('\nNro raices negativas   : %d\n', negativas);
        fprintf('Nro raices positivas   : %d\n', positivas);
        fprintf('Nro raices imaginarias : %d\n', imaginarias);
        fprintf('Nro total de raices : %d\n', total);
        if positivas > 0
            fprintf('El sistema es inestable\n');
        elseif positivas == 0
            fprintf('El sistema es estable\n');
        end
        fprintf('Raices:\n');
        %%roots(sym2poly(n))
        roots(coeffs(n, s));
        if pols ~= 0
            fprintf('Polinomio que da lugar a la fila ceros: %s\n', char(pols));
            %pols
            %N = sym2poly(pols);
            %fprintf('\nRaices del polinomio\n');
            %roots(N)
        end
    end
    [f,c] = size(F);
    epsilon = 0.1;
    if flagsim == true
        for t = 3:f
            if length(F(t,2)) ~= 0
                %%r = double(vpasolve(F(t,2)));
                r = double(F(t,2));
                [n,d] = numden(F(t,2));
                valor1 = subs(n,num2str(r+epsilon));
                valor2 = subs(n,num2str(r-epsilon));
                if valor1 > 0
                    fprintf ("%d) K > %f\n", t, r);
                else
                    fprintf ("%d) K < %f\n", t, r);
                end
            end
        end
    end
end
function[cambiosigno1, cambiosigno2] = analisis(F, pols, ii)
    epsilon = sym("epsilon");
    epsilon = 0.1;
    [f,c] = size(F);
    cambiosigno1 = 0;
    cambiosigno2 = 0;
    ff = f-1;
    if ii > 0
        ff = ii-1;
    end
    for i = 1:ff
        if F(i,2)== epsilon
            F(i,2) = sym(1)/10;
        end
        if sign(F(i,2)) * sign(F(i+1,2)) == -1
            cambiosigno1 = cambiosigno1 + 1;
        end
    end
    if ii > 0
        for i = ii:f-1
            if F(i,2)== epsilon
                F(i,2) = sym(1)/10;
            end
            if sign(F(i,2)) * sign(F(i+1,2)) == -1
                cambiosigno2 = cambiosigno2 + 1;
            end
        end
    end
end
function[] = rango()
    [f,c] = size(F);
    epsilon = 0.1;
    for t = 3:f
        if length(findsymbols(F(1,2))) ~= 0
            r = double(vpasolve(F(t,1), K));
            [n,d] = numden(F(t,1));
            valor1 = subs(n,num2str(r+epsilon));
            valor2 = subs(n,num2str(r-epsilon));
            if valor1 > 0
                printf ("%d) K >= %f\n", t, r);
            else
                printf ("%d) K <= %f\n", t, r);
            end
        end
    end
end
function[filacero] = detectafilacero(B)
    filacero = true;
    [f,c] = size(B);
    for i = 1:c
        if B(1,i) ~= 0
            filacero = false;
        end
    end
end
function[C, pols] = procfilacero(B,c2)
    syms s
    [f4,c4]=size(B);
    j=1;k=1;
    while(j<=c2+1)
        M(1,j)=B(1,k);
        j = j+2;
        k=k+1;
    end
    [f5,c5]=size(M);
    pols = poly2sym(M,s);
    N = sym2poly(diff(pols));
    N = [N 0];
    j=1;k=1;
    while(k<=c2)
        C(1,j)=N(1,k);
        j = j+1;
        k=k+2;
    end
    [f3,c3] = size(C);
    for k = c3:c4-1
      C = [C 0];
    end
end
function[F, pols, ii, flagcero] = proctabla(A, c,flagsim)
    s = sym("s");
    epsilon = sym("epsilon");
    K = sym("K");
    e = sym("e");
    pols = 0;
    ii = 0;
    flagcero = 0;
    [f1,c1]= size(A);
    a=length(find(A(2,:)==K));
    if flagsim == false
        mcd = procmcd(A(2,:));
        if a == 0 && mcd ~= -1
            A(2,:) = A(2,:)/mcd;
        end
    end
    F = [s^(c-1);s^(c-2)];
    F = [F A];
    for i=1:c-2
        D = [];
        A(2,1);
        if A(2,1) == 0;
            flagcero = i;
            A(2,1) = -sym(1)/10;
            F(i+1,2) = -sym(1)/10;
        end
        for j=2:c1
            d =(A(2,1)*A(1,j)-A(1,1)*A(2,j))/A(2,1);
            D = [D d];
        end
        filacero = detectafilacero(D);
        if filacero == true
            ii = i;
            [D, pols] = procfilacero(A(2,:),c-i-1);
        end
        a= length(find(D==K));
        if flagsim == false
            mcd = procmcd(D);
            if a == 0 && mcd ~=-1
                D = D/mcd;
            end
        end
        [f3,c3] = size(D);
        for j = c3:c1-1
            D = [D 0];
        end
        B = [(s^(c-i-2))];
        B = [B D];
        F = [F; B];
        A(1,:) = A(2,:);
        A(2,:) = D;
    end
end
function[mcd] = procmcd(B)
  mcd = -1;
  return
  C = find(B==0);
  B(C)=[];
  [f4,c4] = size(B);
  if c4 ==1
    return;
  end
  mm = double(min(abs(B)));
  [ff,cc] = size(B);
  for cont = mm:-1:1
    mcd = cont;
    for i = 1:cc
      if mod(double(B(1,i)),cont)~=0
        mcd = -1;
      end
    end
    if mcd ~= -1
      return;
    end
  end
end
end

function [error, n, method, symbols, equations, initialConditions, max_iter, epsilon, isIterative] = readfile()
%{
file format:
3                       ->  number of equations (also number of variables)
LU Decomposition        ->  root finding method
a b c                   ->  space separated variable symbols
10*a - 7*b              ->  function 1                           \
-3*a + 2.099*b + 6*c    ->  function 2                            |--> n equations in n lines
5*a - b + 5*c           ->  function 3                           /
0 0 0                   ->  space separated initial conditions   \
100                     ->  maximum number of iterations          |--> only in Gauss Seidel method
1e-05                   ->  minimum allowable relative error     /
%}

    % open file
    filter = {'.txt'};
    [name, path] = uigetfile(filter);
    directory = [path name];
    if length(directory) == 2
        fid = -1;
    else
        fid = fopen(directory);
    end
    % check if file exists
    if (fid < 0)
        error = 'You did not choose a file';
        [n, method, symbols, equations, initialConditions, max_iter, epsilon, isIterative] = setDefaults();
        return;
    end
    % read number of equations
    n = fgetl(fid);
    % read method name
    method = fgetl(fid);
    % read symbols
    symbols = fgetl(fid);
    % read equations
    [equations, error] = readEquations(n, fid);
    if error ~= 0
        [n, method, symbols, equations, initialConditions, max_iter, epsilon, isIterative] = setDefaults();
        return;
    end
    equations = compose(equations);     % convert \n to actual newlines
    % read special inputs for Gauss-Seidel Method
    isIterative = false;
    if strcmp(method, 'Gauss-Seidel Method') || strcmp(method, 'All')
        initialConditions = fgetl(fid);
        max_iter = fgetl(fid);
        epsilon = fgetl(fid);
        isIterative = true;
    end
    % close file
    fclose(fid);
    % No errors
    error = 0;
end

function [n, method, symbols, equations, initialConditions, max_iter, epsilon, isIterative] = setDefaults()
    n = '';
    method = '';
    symbols = '';
    equations = '';
    initialConditions = '';
    max_iter = '';
    epsilon = '';
    isIterative = '';
end

function [equations, error] = readEquations(n, fid)
    error = 0;
    count = str2double(n);
    if(~isequaln(count, NaN) && length(count)==1)
        if count < 1
            error = 'Invalid format for Number of Equations';
            return;
        end
        equations = fgetl(fid);
        if equations == -1
            error = 'Equations are missing';
            return;
        end
        if count ~= 1
            for i = 2 : count
                eqn = fgetl(fid);
                if eqn == -1
                    error = sprintf('%d equations are missing', count-i);
                    return;
                end
                equations = equations + "\n" + eqn;
            end
        end
    else
        error = 'Invalid format for Number of Equations';
        return;
    end
end
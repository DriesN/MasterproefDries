function [x,cost] = fminsearchbound(handle,x0,lb,ub,varargin)
% [x,cost] = fminsearchbound(handle,x0,lb,ub,varargin)

    % input handling
    x0 = x0(:);
    lb = lb(:);
    ub = ub(:);
    
    if ~isempty(lb)
        lb = lb(1:length(x0));
    else
        lb = -1e100;
    end
    if ~isempty(ub)
        ub = ub(1:length(x0));
    else
        ub = 1e100;
    end
    for i = 1:length(x0)
        if x0(i) == lb(i)
            x0(i) = x0(i) + 1e-50;
        elseif x0(i) == ub(i)
            x0(i) = x0(i) - 1e-50;
        end
    end
    
    
    % scaling
    xx0 = (x0-lb)./(ub-lb);
    

    if isempty(varargin)
        [x,cost] = fminsearch(@boundhandle,xx0);
    else
        [x,cost] = fminsearch(@boundhandle,xx0,varargin{1});  
    end
    
    % rescaling
    x = lb + x.*(ub-lb);
    
    %{
    function cost = boundhandle(x)
        if sum(x >= 0 ) == length(x) && sum(x <= 1 ) == length(x)
            cost = handle(lb+x.*(ub-lb));
        else
            cost = 1e100;
        end
    end
    %}
    


    function cost = boundhandle(x)
        k = 1000;
        % multiplication function
        f = prod(  1./(1+exp(k*(x-1))) - 1./(1+exp(k*(x-0)))  ).^-1;
        
        % limit variable to theri bounds
        x = min(1,max(0,x));
        cost = f*handle(lb+x.*(ub-lb));
    end

end
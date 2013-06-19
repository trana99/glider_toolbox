function [filled, invalid] = fillInvalidValues(varargin)
%FILLINVALIDVALUES  Fill invalid values in sequence with given method.
%
%  Syntax:
%    FILLED = FILLINVALIDVALUES(X, Y, METHOD)
%    FILLED = FILLINVALIDVALUES(X, Y, VALUE)
%    FILLED = FILLINVALIDVALUES(X, Y)
%    FILLED = FILLINVALIDVALUES(Y, METHOD)
%    FILLED = FILLINVALIDVALUES(Y, VALUE)
%    FILLED = FILLINVALIDVALUES(Y)
%    [FILLED, INVALID] = FILLINVALIDVALUES(...)
%
%  FILLED = FILLINVALIDVALUES(X, Y, METHOD) fills invalid values (NaN) in vector
%  Y, using the method specified by string METHOD, which is one of:
%    'none': do nothing, X is ignored and Y is returned.
%    'previous': previous valid value found (if any), X is ignored.
%    'next': next valid value found (if any), X is ignored.
%    'nearest', 'linear', 'spline', 'pchip' and 'cubic': interpolate valid 
%      values in Y over corresponding entries in independent variable vector X 
%      using function INTERP1 with given method. X and Y should have the same 
%      dimensions.
%  FILLED is a a copy of vector Y but with invalid values filled.
%
%  FILLED = FILLINVALIDVALUES(X, Y, VALUE) fills invalid values in X
%  using number VALUE as fill value. X is ignored.
%
%  FILLED = FILLINVALIDVALUES(X, Y) fills invalid values in X
%  using 'linear' as default interpolation method.
%
%  FILLED = FILLINVALIDVALUES(Y, ...) assumes that X = 1:N, where N is the 
%  length of Y. Please note that this is only relevant when used with
%  interpolation methods: 'nearest', 'linear', 'spline', 'pchip' or 'cubic'.
%
%  [FILLED, INVALID] = FILLINVALIDVALUES(...) also returns a logical vector
%  INVALID with the same dimensions as Y, showing whether respective entries in
%  Y are invalid values.
%
%  Examples:
%    x = [0 2 4 8 10 12 14 16 18 20]
%    y = [0 nan 16 64 nan nan nan 256 324 400] % y = x.^2
%    % Default linear interpolation over 1:N.
%    filled = fillInvalidValues(y)
%    % Default linear interpolation over given independent coordinates.
%    filled = fillInvalidValues(x, y)
%    % Interpolation using cubic splines given independent coordinates.
%    filled = fillInvalidValues(x, y, 'cubic')
%    % Fill with previous valid value (x not needed but could be there).
%    filled = fillInvalidValues(y, 'previous')
%    filled = fillInvalidValues(x, y, 'previous')
%    % Fill with next valid value (x not needed but could be there).
%    filled = fillInvalidValues(y, 'next')
%    filled = fillInvalidValues(x, y, 'next')
%    % Fill with given value (x not needed but could be there).
%    filled = fillInvalidValues(x, y, 0)
%    filled = fillInvalidValues(y, 0)
%    % Get also the index of invalid entries in Y.
%    [filled, invalid] = fillInvalidValues(x, y)
%
%  See also:
%    INTERP1
%    ISNAN
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  error(nargchk(1, 3, nargin, 'struct'));
  
  switch nargin
    case 1
      y = varargin{1};
      x = 1:numel(y);
      method = 'linear';
    case 2
      if ischar(varargin{2}) || isscalar(varargin{2})
        y = varargin{1};
        x = 1:numel(y);
        method = varargin{2};
      else
        x = varargin{1};
        y = varargin{2};
        method = 'linear';
      end
    otherwise
      x = varargin{1};
      y = varargin{2};
      method = varargin{3};
  end
  
  invalid = isnan(y);
  
  if ischar(method)
    % Fill invalid values with given method.
    switch lower(method)
      case 'none'
        filled = y;
      case 'previous'
        filled = y;
        ind_val = find(~invalid);        
        for i = 1:(numel(ind_val)-1)
          first = ind_val(i) + 1;
          last = ind_val(i+1) - 1;
          value = y(ind_val(i));
          filled(first:last) = value;
        end
      case 'next'
        filled = y;
        ind_val = find(~invalid);        
        for i = 1:(numel(ind_val)-1)
          first = ind_val(i) + 1;
          last = ind_val(i+1) - 1;
          value = y(ind_val(i+1));
          filled(first:last) = value;
        end
      case {'nearest', 'linear', 'spline', 'pchip', 'cubic'}
        filled = y;
        filled(invalid) = ...
          interp1(x(~invalid), y(~invalid), x(invalid), lower(method));
      otherwise
        error('glider_toolbox:fillInvalidValues:InvalidMethod', ...
              'Invalid method: %s.', method);
    end
  else
    % Fill invalid values with given scalar value.
    filled = y;
    filled(invalid) = method;
  end

end
 % Indicates if the mouse pointer is within certain bounds
 function out = isWithinBounds(pos, bounds)
      x  = pos(1);      y  = pos(2);
      lx = bounds(1);   ly = bounds(2);
      lw = bounds(3);   lh = bounds(4);
      
      if x>=lx && x<=(lx+lw) && y>=ly && y<=(ly+lh)
          out = 1;
      else
          out = 0;
      end   
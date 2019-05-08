class MyOde

  # array of the points in the domain at which the numerical solution was evaluated
  attr_reader :x
  # number of points (i.e. length of +x+)
  attr_reader :mx
  # value of f at every point in x
  attr_reader :fx
  # the numerical solution as an array
  attr_reader :u
  # the error tolerance of the method (only applicable for methods with automatic step size adjustment)
  attr_reader :tol
  # the numerical scheme applied
  attr_reader :method

  attr_reader :xini

  def initialize(xrange:, dx:, yini:, tol: 1e-2, maxiter: 1e6, method: :dopri, xini: 0.0, &f)

    raise(ArgumentError, "Expected xrange to be an array of length 2") unless xrange.length == 2
    @dx = dx
    @xmin = xrange[0]
    @xmax = xrange[1]
    @yini = yini
    @maxiter = maxiter
    @tol = tol
    @f = f
    @xini = xini
    @x = [] # Stores the x grid
    @fx = [] # Stores the values of f at every point in x
    @u = [] # Stores numerical solution

    @method = method
    case @method
    when :dopri then dopri
    end
  end

    def f(x0, y0, z0)
      @f.call(x0, y0, z0)
    end

    def dopri
      a21 = 1.0/5.0
      a31 = 3.0/40.0
      a32 = 9.0/40.0
      a41 = 44.0/45.0
      a42 = -56.0/15.0
      a43 = 32.0/9.0
      a51 = 19372.0/6561.0
      a52 = -25360.0/2187.0
      a53 = 64448.0/6561.0
      a54 = -212.0/729.0
      a61 = 9017.0/3168.0
      a62 = -355.0/33.0
      a63 = 46732.0/5247.0
      a64 = 49.0/176.0
      a65 = -5103.0/18656.0
      a71 = 35.0/384.0
      a72 = 0.0
      a73 = 500.0/1113.0
      a74 = 125.0/192.0
      a75 = -2187.0/6784.0
      a76 = 11.0/84.0

      c2 = 1.0 / 5.0
      c3 = 3.0 / 10.0
      c4 = 4.0 / 5.0
      c5 = 8.0 / 9.0
      c6 = 1.0
      c7 = 1.0

      b1order5 = 35.0/384.0
      b2order5 = 0.0
      b3order5 = 500.0/1113.0
      b4order5 = 125.0/192.0
      b5order5 = -2187.0/6784.0
      b6order5 = 11.0/84.0
      b7order5 = 0.0

      b1order4 = 5179.0/57600.0
      b2order4 = 0.0
      b3order4 = 7571.0/16695.0
      b4order4 = 393.0/640.0
      b5order4 = -92097.0/339200.0
      b6order4 = 187.0/2100.0
      b7order4 = 1.0/40.0

      @x[0] = @xmin
      @u[0] = @yini
      @fx[0] = self.f(@x[0], @u[0], @xini)
      h = @dx
      i = 0

      0.upto(@maxiter) do |iter|
        # Compute the function values
        k1 = @fx[i]
        k2 = self.f(@x[i] + c2*h, @u[i] + h*(a21*k1), @xini)
        k3 = self.f(@x[i] + c3*h, @u[i] + h*(a31*k1+a32*k2), @xini)
        k4 = self.f(@x[i] + c4*h, @u[i] + h*(a41*k1+a42*k2+a43*k3), @xini)
        k5 = self.f(@x[i] + c5*h, @u[i] + h*(a51*k1+a52*k2+a53*k3+a54*k4), @xini)
        k6 = self.f(@x[i] +    h, @u[i] + h*(a61*k1+a62*k2+a63*k3+a64*k4+a65*k5), @xini)
        k7 = self.f(@x[i] +    h, @u[i] + h*(a71*k1+a72*k2+a73*k3+a74*k4+a75*k5+a76*k6), @xini)

        error = (b1order5 - b1order4)*k1 + (b3order5 - b3order4)*k3 + (b4order5 - b4order4)*k4 +
            (b5order5 - b5order4)*k5 + (b6order5 - b6order4)*k6 + (b7order5 - b7order4)*k7
        error = error.abs

        # error control
        if error < @tol then
          @x[i+1] = @x[i] + @dx #h
          @u[i+1] = @u[i] + h * (b1order5*k1 + b3order5*k3 + b4order5*k4 + b5order5*k5 + b6order5*k6)
          @fx[i+1] = self.f(@x[i+1], @u[i+1], xini)
          i = i+1
        end

        delta = 0.84 * (@tol / error)**0.2 if error != 0.0
        delta = 0.0 if error == 0.0

        if delta <= 0.1 then
          h = h * 0.1
        elsif delta >= 4.0 then
          h = h * 4.0
        else
          h = delta * h
        end

        # set h to the user specified maximal allowed value
        h = @dx if h > @dx

        if @x[i] >= @xmax then
          break
        elsif @x[i] + h > @xmax then
          h = @xmax - @x[i]
        end
      end

      @mx = @x.length # Number of x steps

      raise(RuntimeError, "Maximal number of iterations reached
              before evaluation of the solution on the entire x interval
              was completed (try to increase maxiter or use a different method") if @x.last < @xmax
    end
end

require "gnuplot"
require 'matplotlib/pyplot'

r = 1.1   # rozrodczość ofiar V
a = 0.01   # skuteczność drapieżnika
s = 1.1   # śmiertelność
b = 1.15  # biomasa => b * a = wzrost drapieżników p

V_function = proc { |t,v,p| r*v-a*v*p }
P_function = proc { |t,p,v| -s*p+a*b*v*p }

xrange    = [0.0, 100.0]
@dx       = 0.001
@maxiter  = 1e10
@tol      = 1e-14

@P_value = 101.0
@V_value = 125.0
@v = []
@p = []
@t = []

0.upto(xrange[1]/@dx) do |iter|

  dopri_sol2 = MyOde.new(xrange: [iter*@dx, iter*@dx+@dx], dx: @dx, yini: @P_value,
                         tol: @tol, maxiter: @maxiter, xini: @V_value, &P_function)
  dopri_sol  = MyOde.new(xrange: [iter*@dx, iter*@dx+@dx], dx: @dx, yini: @V_value,
                         tol: @tol, maxiter: @maxiter, xini: @P_value, &V_function)

  @P_value = dopri_sol2.u[1]
  @V_value = dopri_sol.u[1]
  @v[iter] = @V_value
  @p[iter] = @P_value
  @t[iter] = iter*@dx
end

plot = Matplotlib::Pyplot
plot.plot(@t, @v)
plot.plot(@t, @p)
plot.show()
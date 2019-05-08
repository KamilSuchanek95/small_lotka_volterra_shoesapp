require 'spitzy'
require 'sciruby'
require 'gnuplot'

r = 0.3
a = 0.1
s = 1.5
b = 0.75
v = 1.0
p = 1.0

V_function = proc { |t,v| r*v-a*v*p }
P_function = proc { |t,p| -s*p+a*b*v*p }

dopri_sol = Spitzy::Ode.new(xrange: [0.0,40.0], dx: 0.1, yini: 10.0,
                            tol: 1e-6, maxiter: 1e6, &P_function)


Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title "Test"
    plot.xlabel "x"
    plot.ylabel "y"
    x = dopri_sol.x.flatten
    u = dopri_sol.u.flatten
    plot.data << Gnuplot::DataSet.new(u) do |ds|
      ds.with = "points"
      ds.title = "Numerical Solution"
    end
  end
end


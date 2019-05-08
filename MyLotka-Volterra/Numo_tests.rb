require 'numo/gnuplot'
#
#@r = 1.10   # rozrodczość ofiar V
#@a = 0.1   # skuteczność drapieżnika P
#@s = 3.10   # śmiertelność
#@b = 1.15  # biomasa => b * a = wzrost drapieżników p
#
#trange    = [0.0, 30.0]
#@dt       = 0.001
#
#@P_value = 101.0
#@V_value = 125.0
#@v = []
#@p = []
#@t = []
#
#def f(v, p)
#  dvdt =  @r*v-@a*v*p
#  dpdt = -@s*p+@a*@b*v*p
#  return dvdt, dpdt
#end
#
#def dormand_price_two_equations(v:, p:)
#  vdot1, pdot1 = f(v, p)
#  vdot2, pdot2 = f(v + vdot1 * @dt/2.0, p + pdot1 * @dt/2.0)
#  vdot3, pdot3 = f(v + vdot2 * @dt/2.0, p + pdot2 * @dt/2.0)
#  vdot4, pdot4 = f(v + vdot3 * @dt    , p + pdot3 * @dt)
#  vnew = v + (vdot1 + 2.0 * vdot2 + 2.0 * vdot3 + vdot4) * @dt/6.0
#  pnew = p + (pdot1 + 2.0 * pdot2 + 2.0 * pdot3 + pdot4) * @dt/6.0
#  return vnew, pnew
#end
#
#@v[0] = @V_value
#@p[0] = @P_value
#@t[0] = -10.0
#
#0.upto(trange[1]/@dt) do |iter|
#  @v[iter+1], @p[iter+1] = dormand_price_two_equations(v: @v[iter], p: @p[iter])
#  @t[iter+1] = (1+iter) * @dt
#end

#Numo.gnuplot do
#  set title:"Simulation of Lotka-Volterra small model\nparameters =>    r:#{@r}    a:#{@a}    s:#{@s}    b:#{@b}    for t_m_a_x:#{trange[1]}    dt:#{@dt}"
#  set grid:true
#  set xrange:trange[0]..trange[1]
#  set key_title: "Przebiegi"
#  plot [@t, @v, w:"lines", ls: 4, lw:1, t:"Preys"],
#               [@t, @p, w:"lines", ls: 1, lw:1, t:"Predators"]
#  plot @v, @p, t:"Phase Portrait", w: :lines
#  set title:"Phase Portrait of Lotka-Volterra small model"
#  set grid:true
#end

Numo.gnuplot do
  set :multiplot, title:"Demo of placing multiple plots (2D and 3D)\nwith explicit alignment of plot borders"
  set :rmargin, :at, screen:0.85
  set :bmargin, :at, screen:0.25
  set :tmargin, :at, screen:0.90
  set :pm3d
  set :palette, rgbformulae:[7,5,15]
  set view:'map'
  set samples:[50,50]
  set isosamples:[50,50]
  unset :surface
  set xrange:-15.00..15.00
  set yrange:-15.00..15.00
  set zrange:-0.250..1.000
  unset :xtics
  unset :ytics
  set :key, "above"
  splot "sin(sqrt(x**2+y**2))/sqrt(x**2+y**2)"
  unset :pm3d
  unset :key
  set :lmargin, :at, screen:0.10
  set :rmargin, :at, screen:0.20
  set :ytics
  set :parametric
  set dummy:"u,v"
  set view:'map'
  run "f(h) = sin(sqrt(h**2))/sqrt(h**2)"
  set urange:-15.00..15.00
  set vrange:-15.00..15.00
  set xrange:"[*:*]"
  set :surface
  splot "f(u)",
        "u",
        ["0", with:"lines", lc_rgb:"green"]
  unset :parametric
  set :lmargin, :at, screen:0.20
  set :rmargin, :at, screen:0.85
  set :bmargin, :at, screen:0.10
  set :tmargin, :at, screen:0.25
  set xrange:-15.00..15.00
  set yrange:"[*:*]"
  set :xtics
  unset :ytics
  run "y = 0"
  plot "sin(sqrt(x**2+y**2))/sqrt(x**2+y**2)"
  unset :multiplot
end


puts "miaona"
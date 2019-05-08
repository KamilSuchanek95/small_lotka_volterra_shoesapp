require 'gnuplot'
require 'matplotlib/pyplot'
require 'numo/gnuplot'

class Miaona
  attr_reader :v, :p, :t, :r, :a, :s, :b, :trange, :dt

  def initialize(r:, a:, s:, b:, trange:, dt:, p_init:, v_init:)
    @r = r#1.10   rozrodczość ofiar V
    @a = a#0.01   skuteczność drapieżnika
    @s = s#3.10    śmiertelność
    @b = b#1.15   biomasa => b * a = wzrost drapieżników p
    @trange = trange#[0.0, 30.0]
    @dt = dt#0.1
    @P_init = p_init#101.0
    @V_init = v_init#125.0
    @v = []
    @p = []
    @t = []

    solveit
    return @v, @p, @t
  end

  def f(v, p)
    dvdt =  @r*v-@a*v*p
    dpdt = -@s*p+@a*@b*v*p
    return dvdt, dpdt
  end

  def dormand_price_two_equations(v, p)
    vdot1, pdot1 = self.f(v, p)
    vdot2, pdot2 = self.f(v + vdot1 * @dt/2.0, p + pdot1 * @dt/2.0)
    vdot3, pdot3 = self.f(v + vdot2 * @dt/2.0, p + pdot2 * @dt/2.0)
    vdot4, pdot4 = self.f(v + vdot3 * @dt    , p + pdot3 * @dt)
    vnew = v + (vdot1 + 2.0 * vdot2 + 2.0 * vdot3 + vdot4) * @dt/6.0
    pnew = p + (pdot1 + 2.0 * pdot2 + 2.0 * pdot3 + pdot4) * @dt/6.0
    return vnew, pnew
  end

  def solveit()
    @v[0] = @V_init
    @p[0] = @P_init
    @t[0] = 0.0
    0.upto(@trange[1]/@dt) do |iter|
      @v[iter+1], @p[iter+1] = self.dormand_price_two_equations(@v[iter], @p[iter])
      @t[iter+1] = (1+iter) * @dt
    end
  end

end

miaona = Miaona.new(r: 4.10, a: 0.01, s: 1.10, b:1.15, trange: [0.0, 30.0], dt: 0.1, p_init: 101.0, v_init: 125.0)

@v,@p = miaona.v, miaona.p
@t = miaona.t
@trange = miaona.trange
@dt = miaona.dt
@r = miaona.r
@a = miaona.a
@s = miaona.s

#gnuplot.set :multiplot, layout: [2,1],scale: [1,1], title: "Small Lotka-Volterra Model"


gnuplot = Numo::Gnuplot.new
gnuplot.set terminal: :pngcairo, size: [3000, 1000]
gnuplot.set output: ['miau.png']
gnuplot.set title:"Simulation\nparameters =>    r:#{@r}    a:#{@a}    s:#{@s}    b:#{@b}    for t_m_a_x:#{@trange[1]}    dt:#{@dt}"
gnuplot.set grid:true, lw: 3
gnuplot.set border: 3
gnuplot.set xrange: @trange[0]..@trange[1]
gnuplot.set key_title: "Przebiegi"
gnuplot.plot [@t, @v, w:"linespoints", pt: 6, lt: {rgb: '#5e9c36', lw:2}, t:"Preys"],
             [@t, @p, w:"linespoints", pt: 1, lt: {rgb: '#8b1a0e', lw:2}, t:"Predators"]


gnuplot2 = Numo::Gnuplot.new
gnuplot2.set terminal: :pngcairo, size: [1000, 1000]
gnuplot2.set output: ['miau2.png']
gnuplot2.set title:"Phase Portrait of Lotka-Volterra small model"
gnuplot2.set border: 3
gnuplot2.set grid: true, lw: 3
gnuplot2.plot @v, @p, t:"Phase one", w:"linespoints", lt: {rgb:"#E9B644", lw:0.5}
gnuplot2.set terminal: :dat
gnuplot2.plot 'miau2.txt'

#gnuplot2.set xrange:@v.min.to_i..@v.max.to_i
#gnuplot2.set yrange:@p.min.to_i..@p.max.to_i
puts("koniec")
#plot = Matplotlib::Pyplot
#plot.plot(@t, @v)
#plot.plot(@t, @p)
#plot.show()


#Gnuplot.open do |gp|
#  Gnuplot::Plot.new(gp) do |plot|
#    plot.title "Simulation, parameters =>    r:#{@r}    a:#{@a}    s:#{@s}    b:#{@b}    for t_m_a_x:#{trange[1]}    dt:#{@dt}"
#    plot.xlabel "time"
#    plot.ylabel "Populations"
#
#    plot.data << Gnuplot::DataSet.new([@t, @p]) do |ds|
#      ds.with = "lines"
#      ds.title = "Numerical Solution P"
#    end
#    plot.data << Gnuplot::DataSet.new([@t, @v]) do |ds|
#      ds.with = "lines"
#      ds.title = "Numerical Solution V"
#    end
#  end
#end

require 'gnuplot'
require 'matplotlib/pyplot'
require 'numo/gnuplot'

class Miaona
  attr_reader :v, :p, :t, :r, :a, :s, :b, :trange, :dt, :p_lim_env, :v_lim_env, :k

  def initialize(r:, a:, s:, b:, trange:, dt:, p_init:, v_init:, k:)
    @r = r#1.10   rozrodczość ofiar V
    @a = a#0.01   skuteczność drapieżnika
    @s = s#3.10    śmiertelność
    @b = b#1.15   biomasa => b * a = wzrost drapieżników p
    @trange = trange#[0.0, 30.0]
    @dt = dt#0.1
    @P_init = p_init#101.0
    @V_init = v_init#125.0
    @v = []
    @p_lim_env = []
    @v_lim_env = []
    @p = []
    @t = []
    @k = k#pojemność środowiska
    solveit
    return @v, @p, @t
  end

  def f_lim_env(v, p)
    dvdt =  @r*v*(1.0-(v/@k))-@a*v*p
    dpdt = -@s*p+@a*@b*v*p
    return dvdt, dpdt
  end

  def f(v, p)
    dvdt =  @r*v-@a*v*p
    dpdt = -@s*p+@a*@b*v*p
    return dvdt, dpdt
  end

  def dormand_price_two_equations(v, p, v_lim_env, p_lim_env)
    vdot1, pdot1 = self.f(v, p)
    vdot2, pdot2 = self.f(v + vdot1 * @dt/2.0, p + pdot1 * @dt/2.0)
    vdot3, pdot3 = self.f(v + vdot2 * @dt/2.0, p + pdot2 * @dt/2.0)
    vdot4, pdot4 = self.f(v + vdot3 * @dt    , p + pdot3 * @dt)

    vnew = v + (vdot1 + 2.0 * vdot2 + 2.0 * vdot3 + vdot4) * @dt/6.0
    pnew = p + (pdot1 + 2.0 * pdot2 + 2.0 * pdot3 + pdot4) * @dt/6.0
    #_lim_env
    vdot1_lim_env, pdot1_lim_env = self.f_lim_env(v_lim_env, p_lim_env)
    vdot2_lim_env, pdot2_lim_env = self.f_lim_env(v_lim_env + vdot1_lim_env * @dt/2.0, p_lim_env + pdot1_lim_env * @dt/2.0)
    vdot3_lim_env, pdot3_lim_env = self.f_lim_env(v_lim_env + vdot2_lim_env * @dt/2.0, p_lim_env + pdot2_lim_env * @dt/2.0)
    vdot4_lim_env, pdot4_lim_env = self.f_lim_env(v_lim_env + vdot3_lim_env * @dt    , p_lim_env + pdot3_lim_env * @dt)
    vnew_lim_env = v_lim_env + (vdot1_lim_env + 2.0 * vdot2_lim_env + 2.0 * vdot3_lim_env + vdot4_lim_env) * @dt/6.0
    pnew_lim_env = p_lim_env + (pdot1_lim_env + 2.0 * pdot2_lim_env + 2.0 * pdot3_lim_env + pdot4_lim_env) * @dt/6.0


    return vnew, pnew, vnew_lim_env, pnew_lim_env
  end

  def solveit()
    @v[0] = @V_init
    @p[0] = @P_init
    @v_lim_env[0] = @V_init
    @p_lim_env[0] = @P_init
    @t[0] = 0.0
    0.upto(@trange[1]/@dt) do |iter|
      @v[iter+1], @p[iter+1], @v_lim_env[iter+1], @p_lim_env[iter+1] = self.dormand_price_two_equations(@v[iter], @p[iter], @v_lim_env[iter], @p_lim_env[iter])
      @t[iter+1] = (1+iter) * @dt
    end
  end

end

miaona = Miaona.new(r: 10.10, a: 0.1, s: 1.10, b: 1.1,
                    trange: [0.0, 100.0], dt: 0.1,
                    p_init: 101.0, v_init: 125.0, k: 1000)

@v,@p = miaona.v, miaona.p
@v_lim_env,@p_lim_env = miaona.v_lim_env, miaona.p_lim_env
@t = miaona.t
@trange = miaona.trange
@dt = miaona.dt
@r = miaona.r
@a = miaona.a
@s = miaona.s
@b = miaona.b
@k = miaona.k
#gnuplot.set :multiplot, layout: [2,1],scale: [1,1], title: "Small Lotka-Volterra Model"

#gnuplot for normal VT#######################################################################################
gnuplot = Numo::Gnuplot.new
#set terminal and output
gnuplot.set terminal: :pngcairo, size: [3000, 1000]
gnuplot.set output: ["image_charts/sim_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}.png"]
#set title
gnuplot.set title:"Simulation\nparameters =>  r:#{@r}  a:#{@a}  s:#{@s}  b:#{@b}  t_m_a_x:#{@trange[1]}  dt:#{@dt} ", font: "Times Italic, 50"
#set axis
gnuplot.set grid:true, lw: 8
gnuplot.set border: 3
gnuplot.set lmargin: 13
gnuplot.set bmargin: 5
gnuplot.set ylabel: "population", font: "Times Italic, 45", offset: [-4,0,0]
gnuplot.set xlabel: "time", font: "Times Italic, 45"
gnuplot.set xtics: {font: "Times Italic, 25"}
gnuplot.set ytics: {font: "Times Italic, 25"}
gnuplot.set xrange: @trange[0]..@trange[1]
#set legend
gnuplot.set key: :center_top_box
gnuplot.set key_font: "Times Italic, 35"
#plot data
gnuplot.plot [@t, @v, w:"linespoints", pt: 6, lt: {rgb: '#5e9c36', lw:2}, t:"Preys"],
             [@t, @p, w:"linespoints", pt: 1, lt: {rgb: '#8b1a0e', lw:2}, t:"Predators"]

#gnuplot for normal VT Phase###############################################################################
gnuplot = Numo::Gnuplot.new
#set terminal and output
gnuplot.set terminal: :pngcairo, size: [1000, 1000]
gnuplot.set output: ["image_charts/phase_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}.png"]
#set title
gnuplot.set title:"Phase Portrait of Lotka-Volterra small model", font: "Times Italic, 30"
#set axis
gnuplot.set grid:true, lw: 5
gnuplot.set border: 3
gnuplot.set lmargin: 13
gnuplot.set bmargin: 5
gnuplot.set ylabel: "Preys population", font: "Times Italic, 25", offset: [-4,0,0]
gnuplot.set xlabel: "Predators population", font: "Times Italic, 25", offset: [0,-1,0]
gnuplot.set xtics: {font: "Times Italic, 25"}
gnuplot.set ytics: {font: "Times Italic, 25"}
#set legend
gnuplot.set key_off: true
#plot data
gnuplot.plot @v, @p, w:"lines", lt: {rgb:"#E9B644", lw:1}

#gnuplot for limitation of the environment###################################################################
gnuplot = Numo::Gnuplot.new
#set terminal and output
gnuplot.set terminal: :pngcairo, size: [3000, 1000]
gnuplot.set output: ["image_charts/sim_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}_k:#{@k}.png"]
#set title
gnuplot.set title:"Simulation with limitation of the environment\nparameters =>    r:#{@r}    a:#{@a}    s:#{@s}    b:#{@b}    for t_m_a_x:#{@trange[1]}    dt:#{@dt}    K:#{@k}", font: "Times Italic, 50"
#set axis
gnuplot.set grid:true, lw: 8
gnuplot.set border: 3
gnuplot.set lmargin: 13
gnuplot.set bmargin: 5
gnuplot.set ylabel: "population", font: "Times Italic, 45", offset: [-4,0,0]
gnuplot.set xlabel: "time", font: "Times Italic, 45"
gnuplot.set xtics: {font: "Times Italic, 25"}
gnuplot.set ytics: {font: "Times Italic, 25"}
gnuplot.set xrange: @trange[0]..@trange[1]
#set legend
gnuplot.set key: :center_top_box
gnuplot.set key_font: "Times Italic, 35"
#plot data
gnuplot.plot [@t, @v_lim_env, w: "linespoints", pt: 6, lt: {rgb: '#5e9c36', lw:2}, t:"Preys"],
             [@t, @p_lim_env, w: "linespoints", pt: 1, lt: {rgb: '#8b1a0e', lw:2}, t:"Predators"]
#gnuplot for limitation of the environment Phase##############################################################
gnuplot = Numo::Gnuplot.new
#set terminal and output
gnuplot.set terminal: :pngcairo, size: [1000, 1000]
gnuplot.set output: ["image_charts/phase_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}_k:#{@k}.png"]
#set title
gnuplot.set title:"Phase Portrait of Lotka-Volterra small model\nLimitation of the environment", font: "Times Italic, 30"
#set axis
gnuplot.set grid:true, lw: 5
gnuplot.set border: 3
gnuplot.set lmargin: 13
gnuplot.set bmargin: 5
gnuplot.set ylabel: "Preys population", font: "Times Italic, 25", offset: [-4,0,0]
gnuplot.set xlabel: "Predators population", font: "Times Italic, 25", offset: [0,-1,0]
gnuplot.set xtics: {font: "Times Italic, 25"}
gnuplot.set ytics: {font: "Times Italic, 25"}
#set legend
gnuplot.set key_off: true
#plot data
gnuplot.plot @v_lim_env, @p_lim_env, w:"linespoints", lt: {rgb:"#E9B644", lw:1}

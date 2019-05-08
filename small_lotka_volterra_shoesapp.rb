#!/bin/env ruby
# encoding: utf-8
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
    vk1, pk1 = self.f(v, p)
    vk2, pk2 = self.f(v + vk1 * @dt/2.0, p + pk1 * @dt/2.0)
    vk3, pk3 = self.f(v + vk2 * @dt/2.0, p + pk2 * @dt/2.0)
    vk4, pk4 = self.f(v + vk3 * @dt    , p + pk3 * @dt)

    vnew = v + (vk1 + 2.0 * vk2 + 2.0 * vk3 + vk4) * @dt/6.0
    pnew = p + (pk1 + 2.0 * pk2 + 2.0 * pk3 + pk4) * @dt/6.0
    #_lim_env
    vk1_lim_env, pk1_lim_env = self.f_lim_env(v_lim_env, p_lim_env)
    vk2_lim_env, pk2_lim_env = self.f_lim_env(v_lim_env + vk1_lim_env * @dt/2.0, p_lim_env + pk1_lim_env * @dt/2.0)
    vk3_lim_env, pk3_lim_env = self.f_lim_env(v_lim_env + vk2_lim_env * @dt/2.0, p_lim_env + pk2_lim_env * @dt/2.0)
    vk4_lim_env, pk4_lim_env = self.f_lim_env(v_lim_env + vk3_lim_env * @dt    , p_lim_env + pk3_lim_env * @dt)
    vnew_lim_env = v_lim_env + (vk1_lim_env + 2.0 * vk2_lim_env + 2.0 * vk3_lim_env + vk4_lim_env) * @dt/6.0
    pnew_lim_env = p_lim_env + (pk1_lim_env + 2.0 * pk2_lim_env + 2.0 * pk3_lim_env + pk4_lim_env) * @dt/6.0


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

@app=Shoes.app(title: "Small Lotka-Volterra App", height: 750, resizable: true) do
  background darkslategray
def center(elem)
  top=(elem.parent.height-elem.style[:height])/2
  left=(elem.parent.width-elem.style[:width])/2
  elem.move(left,top)
end
  @path_of_phase = "image_start/phase.png"
  @path_of_phase_lim_env = "image_start/phase_lim_env.png"
  @path_of_simul = "image_start/simul.png"
  @path_of_simul_lim_env = "image_start/simul_lim_env.png"
  @width_of_edit_line = 55
  @Plotting_flag = false
  @r, @a, @s, @b, @trange, @dt, @p_init, @v_init, @k = 1.1, 0.01, 0.1, 0.1, [0.0, 100.0], 0.1, 101.0, 125.0, 10000
  @button_jumping = @button_save_parameters

  animate do |i|
    @button_jumping.displace(0, (Math.sin(i) * 6).to_i)
  end

  animate do |i|
    h = (self.height*0.40).to_i
    @Simulation.width = self.width
    @Simulation.height = h
    @Simulation_lim_env.width = self.width
    @Simulation_lim_env.height = h
    #w = (0.1*self.width).to_i
    #@stack_edit_lines.margin_right = w
    #@stack_edit_lines.margin_left = w
    center(@stack_edit_lines)
  end
  
  @stack_edit_lines = stack do
    flow do # flow of editing parameters
      para "r = ", stroke: white
      @param_r = edit_line width: @width_of_edit_line, height: 30 
      @param_r.text = "1.1"
      para "a = ", stroke: white
      @param_a = edit_line width: @width_of_edit_line, height: 30
      @param_a.text = "0.01"
      para "s = ", stroke: white
      @param_s = edit_line width: @width_of_edit_line, height: 30
      @param_s.text = "0.1" 
      para "b = ", stroke: white
      @param_b = edit_line width: @width_of_edit_line, height: 30
      @param_b.text = "0.1"
      para "k = ", stroke: white
      @param_k = edit_line width: @width_of_edit_line, height: 30
      @param_k.text = "10000" 
    end
    flow do
      para "time simulation = (", stroke: white
      @param_t1 = edit_line width: @width_of_edit_line, height: 30, margin_right: 0
      @param_t1.text = "0.0" 
      para ",", stroke: white
      @param_t2 = edit_line width: @width_of_edit_line, height: 30
      @param_t2.text = "100.0" 
      para ")", stroke: white
      para "step = ", stroke: white
      @param_dt = edit_line width: @width_of_edit_line, height: 30
      @param_dt.text = "0.1"
    end
    flow do
      para "Initial value P = ", stroke: white
      @param_init_p = edit_line width: @width_of_edit_line, height: 30
      @param_init_p.text = "101.0" 
      para "Initial value V = ", stroke: white
      @param_init_v = edit_line width: @width_of_edit_line, height: 30
      @param_init_v.text = "125.0" 
    end
  end
###################################### buttons
  flow margin_top: 12, margin_bottom: 12 do #1

    @button_save_parameters = button "Save parameters!" do 
      @r, @a, @s, @b, @trange, @dt, @p_init, @v_init, @k  = @param_r.text.to_f, @param_a.text.to_f, @param_s.text.to_f, @param_b.text.to_f, [@param_t1.text.to_f, @param_t2.text.to_f], @param_dt.text.to_f, @param_init_p.text.to_f, @param_init_v.text.to_f, @param_k.text.to_f 
      @button_jumping = @button_calculate_simulation
    end

    @button_calculate_simulation = button "Calculate simulation!" do 
      s = Miaona.new(r: @r, a: @a, s: @s, b: @b, 
                     trange: @trange, dt: @dt, 
                     p_init: @p_init, v_init: @v_init, k: @k)
      @v, @p, @t, @v_lim_env, @p_lim_env = s.v, s.p, s.t, s.v_lim_env, s.p_lim_env

      @Plotting_flag = true
      @button_jumping = @button_plot_it
    end

    @button_plot_it = button "Plot it!" do
      if @Plotting_flag
        #gnuplot for normal VT#######################################################################################
        gnuplot = Numo::Gnuplot.new
        #set terminal and output
        @path_of_simul = "image_charts/sim_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}.png"
        gnuplot.set terminal: :pngcairo, size: [3000, 1000]
        gnuplot.set output: [@path_of_simul]
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
        
        @path_of_phase = "image_charts/phase_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}.png"
        #gnuplot for normal VT Phase###############################################################################
        gnuplot = Numo::Gnuplot.new
        #set terminal and output
        gnuplot.set terminal: :pngcairo, size: [1000, 1000]
        gnuplot.set output: [@path_of_phase]
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
        @path_of_simul_lim_env = "image_charts/sim_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}_k:#{@k}.png"
        #gnuplot for limitation of the environment###################################################################
        gnuplot = Numo::Gnuplot.new
        #set terminal and output
        gnuplot.set terminal: :pngcairo, size: [3000, 1000]
        gnuplot.set output: [@path_of_simul_lim_env]
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
        @path_of_phase_lim_env = "image_charts/phase_r:#{@r}_a:#{@a}_s:#{@s}_b:#{@b}_for_t_m_a_x:#{@trange[1]}_dt:#{@dt}_k:#{@k}.png"
        #gnuplot for limitation of the environment Phase##############################################################
        gnuplot = Numo::Gnuplot.new
        #set terminal and output
        gnuplot.set terminal: :pngcairo, size: [1000, 1000]
        gnuplot.set output: [@path_of_phase_lim_env]
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

        @Simulation.path = @path_of_simul
        @Simulation_lim_env.path = @path_of_simul_lim_env
        @Plotting_flag = false
        @button_jumping = @button_save_parameters
        s, @t, @v, @p = 0, 0, 0, 0
      end
    end
  end#flow 1 - buttons and edit lines
  stack do # stack for Simation graphs
    @Simulation = image @path_of_simul, height: 300, width: 1200, margin_bottom: 10, radius: 12
    @Simulation_lim_env = image @path_of_simul_lim_env, height: 300, width: 1200, radius: 12
    @Simulation.click {
      clipboard = @path_of_phase
      window title: "Phase Portrait" do
        @img = image clipboard
        animate do |i|
          @img.width = self.width
          @img.height = self.height
        end
      end
    }
    @Simulation_lim_env.click {
      clipboard = @path_of_phase_lim_env
      window title: "Phase Portrait of Simulation with limitation of environmet" do
        @img = image clipboard
        animate do |i| 
          @img.width = self.width 
          @img.height = self.height 
        end
      end
    }
  end
  #flow do # flow of Phase Portraits
  #  @Phase_Portrait = image "image_start/phase.png", height: 600, width: 600
  #  @Phase_Portrait_lim_env = image "image_start/phase_lim_env.png", height: 600, width: 600
  #end
end#app
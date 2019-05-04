#!/bin/env ruby
# encoding: utf-8
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
	   	@P_init.to_f
	    @V_init.to_f
	    @v = []
	    @p = []
	    @t = []

	    solveit
	end

	def f(v, p)
	    dvdt =  @r*v-@a*v*p
	    dpdt = -@s*p+@a*@b*v*p
	    return dvdt, dpdt
	end

	def dormand_price_two_equations(v, p)
		vk1, pk1 = self.f(v, p)
	    vk2, pk2 = self.f(v + vk1 * @dt/2.0, p + pk1 * @dt/2.0)
	    vk3, pk3 = self.f(v + vk2 * @dt/2.0, p + pk2 * @dt/2.0)
	    vk4, pk4 = self.f(v + vk3 * @dt    , p + pk3 * @dt)
	    vnew = v + (vk1 + 2.0 * vk2 + 2.0 * vk3 + vk4) * @dt/6.0
	    pnew = p + (pk1 + 2.0 * pk2 + 2.0 * pk3 + pk4) * @dt/6.0
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

Shoes.app(title: "Small Lotka-Volterra App", width: 1200, height: 630, resizable: true) do
	background azure
	stack do#1
		animate do |i|
			@button_plot_it.displace(0, (Math.sin(i) * 6).to_i)
		end
		stack do#2
			flow do #1
				button "Calculate simulation!" do 
					miaona = Miaona.new(r: 1.10, a: 0.01, s: 3.10, b:1.15, trange: [0.0, 50.0], dt: 0.01, p_init: 101.0, v_init: 125.0)
					@v = miaona.v
					@p = miaona.p
					@t = miaona.t
					@r = miaona.r
					@a = miaona.a
					@s = miaona.s
					@b = miaona.b
					@dt= miaona.dt
					@trange = miaona.trange
					@f.toggle()
				end

				@f=flow :hidden => true do
					@button_plot_it = button "Plot it!" do
						cs1 = chart_series values: @v, labels: @t.map(&:to_i).map(&:to_s),
						name: "Preys", min: [@v.min, @p.min].min, max: [@v.max, @p.max].max, desc: "Preys", color: "red",
						points: false, strokewidth: 2

						cs2 = chart_series values: @p, labels: @t.map(&:to_i).map(&:to_s),
						name: "Predators", min: [@v.min, @p.min].min, max: [@v.max, @p.max].max, desc: "Predators", color: "blue",
						points: false, strokewidth: 2
						
						@grf.add cs1
						
						@grf.add cs2
						
						@grf2.add values: @v, labels: @p.uniq.map(&:to_i).map(&:to_s),
						name: "Phase", min: 0, max: [@p.max, @v.max].max, desc: "Phase Portrait", color: "coral",
						points: false, strokewidth: 2

						@f.toggle
					end
				end
			end#flow 1
			flow do#2
				@grf = plot 1200, 300, chart: "timeseries", title: "Simulation", 
				caption: "Solution Through Runge-Kutta 4th Order Method" , 
				font: "Mono", boundary_box: false, auto_grid: true, default: "skip", background: azure
				@grf2 = plot 1200, 300, chart: "timeseries", title: "Phase Portrait", 
				caption: "Stability" , 
				font: "Mono", boundary_box: false, auto_grid: true, default: "skip", background: azure
			end#flow 2
	    end#stack 2
	end#stack 1
end#app
type Palette
	colors::Array{RGBA}

	max_desaturation::Int
end
Palette(strs::Array{ASCIIString},desat::Int) =
	Palette([convert(RGBA{Float64},parse(Colorant,"$s")) for s in strs],desat)
get_color(p::Palette,i) = p.colors[k]
Base.getindex(p::Palette,i) = Base.getindex(p.colors,i)
function get_saturation_transformed_color(p::Palette,i,d::Int,f::Function)
	d=min(p.max_desaturation,d)
	hsva=convert(HSVA{Float64},p[i])
	transformed_hsva=HSVA(hsva.h,f(hsva.s),hsva.v,hsva.alpha)
	return convert(RGBA,transformed_hsva)
end
function get_linear_desaturated_color(p::Palette,i,d::Int)
	return get_saturation_transformed_color(p,i,d,x->x*(1.0-(d-1.0)/(p.max_desaturation-1.0)))
end
function get_exponential_desaturated_color(p::Palette,i,d::Int)
	return get_saturation_transformed_color(p,i,d,x->x*(1.0/exp((d-1)/(p.max_desaturation/5.0))))
end
function get_linear_saturated_color(p::Palette,i,d::Int)
	return get_saturation_transformed_color(p,i,d,x->x+(1.0-x)*(d-1.0)/(p.max_desaturation-1.0))
end
function get_exponential_saturated_color(p::Palette,i,d::Int)
	return get_saturation_transformed_color(p,i,d,
		x->x+(1.0-x)*(1.0-1.0/exp((d-1)/(p.max_desaturation/5.0))))
end

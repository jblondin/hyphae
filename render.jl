using Cairo

rgba_array(rgba::RGBA) = [rgba.r,rgba.g,rgba.b,rgba.alpha]

DEFAULT_LINE_WIDTH=2.0

type Renderer
	front_color::RGBA
	back_color::RGBA
	size::Integer

	surface
	context

	function Renderer(front_color::RGBA,back_color::RGBA,size::Integer)
		surf=CairoRGBSurface(size,size)
		ctx=CairoContext(surf)
		# use values between 0.0 and 1.0 for positioning
		scale(ctx,size,size)
		# draw background
		set_source_rgba(ctx,rgba_array(back_color)...)
		rectangle(ctx,0.0,0.0,1.0,1.0)
		fill(ctx)
		# set basic line width and color
		set_source_rgba(ctx,rgba_array(front_color)...)
		set_line_width(ctx,DEFAULT_LINE_WIDTH)
		new(front_color,back_color,size,surf,ctx)
	end

end

type Point
	x::Real
	y::Real
end

function line(r::Renderer,p1::Point,p2::Point,w::Real,c::RGBA)
	# draw line from p1 to p2
	set_source_rgba(r.context,rgba_array(c)...)
	set_line_width(r.context,w)
	move_to(r.context,p1.x,p1.y)
	line_to(r.context,p2.x,p2.y)
	set_line_cap(r.context, Cairo.CAIRO_LINE_CAP_ROUND);
	stroke(r.context)
end
line(r::Renderer,p1::Point,p2::Point,w::Real) = line(r,p1,p2,w,r.front_color)
line(r::Renderer,p1::Point,p2::Point,c::RGBA) = line(r,p1,p2,DEFAULT_LINE_WIDTH,c)
line(r::Renderer,p1::Point,p2::Point) = line(r,p1,p2,DEFAULT_LINE_WIDTH,r.front_color)
function circle(r::Renderer,p::Point,rad::AbstractFloat)
	# draw circle around p at radius rad
	arc(r.context,p.x,p.y,rad,0.,2.*pi)
	stroke(r.context)
end
function circle_fill(r::Renderer,p::Point,rad::AbstractFloat)
	# draw filled circle around p at radius rad
	arc(r.context,p.x,p.y,rad,0.,2.*pi)
	fill(r.context)
end
function save(r::Renderer,filename::AbstractString)
	write_to_png(r.surface,filename)
end

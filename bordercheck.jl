type SquareBorderCheck
	length::AbstractFloat

	xmin::AbstractFloat
	xmax::AbstractFloat
	ymin::AbstractFloat
	ymax::AbstractFloat
end
function SquareBorderCheck(length::AbstractFloat)
	border=(1.0-length)/2
	SquareBorderCheck(length,border,1.0-border,border,1.0-border)
end
in_bounds(border::SquareBorderCheck,x::AbstractFloat,y::AbstractFloat) =
	x > border.xmin && x < border.xmax && y > border.ymin && y < border.ymax

type CircleBorderCheck
	radius::AbstractFloat
end
in_bounds(border::CircleBorderCheck,x::AbstractFloat,y::AbstractFloat) =
	(x-0.5)*(x-0.5)+(y-0.5)*(y-0.5) < border.radius*border.radius

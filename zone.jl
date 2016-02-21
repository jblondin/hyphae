type ZoneGrid
	n_zones::Int
	nodes_inds_per_zone::Array{Array{Int,1},1}
end
ZoneGrid(n_zones::Int) = ZoneGrid(n_zones,[Array(Int,0) for _ in 1:(n_zones+2)^2])
ZoneGrid(initial_radius::AbstractFloat) = ZoneGrid(floor(Int,1.0/(2.0*initial_radius)))
function get_zone_ind(grid::ZoneGrid,x::Real,y::Real)
	i=1+floor(Int,x*grid.n_zones)
	j=1+floor(Int,y*grid.n_zones)
	return i*(grid.n_zones+2)+j+1
end

function add_node_ind(grid::ZoneGrid,zone_ind::Int,node_ind::Int)
	push!(grid.nodes_inds_per_zone[zone_ind],node_ind)
end
add_node_ind(grid::ZoneGrid,x::Real,y::Real,node_ind::Int) =
	add_node_ind(grid,get_zone_ind(grid,x,y),node_ind)

function get_neighbor_node_inds(grid::ZoneGrid,x::Real,y::Real)
	i=1+floor(Int,x*grid.n_zones)
	j=1+floor(Int,y*grid.n_zones)
	# indices of all neighboring zones (horizontal, vertical, diagonal)
	zone_inds=[i-1,i,i+1,i-1,i,i+1,i-1,i,i+1]*(grid.n_zones+2)+
		[j+1,j+1,j+1,j,j,j,j-1,j-1,j-1]+1

	return reduce(append!,[],grid.nodes_inds_per_zone[zone_inds])

end

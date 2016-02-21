type Node
	x::AbstractFloat		# x position
	y::AbstractFloat		# y position
	theta::AbstractFloat	# direction of branch
	depth::Int 				# depth of tree
	n_branches::Int 		# number of branches from this node
	radius::AbstractFloat	# radius of search circle
	has_descendant			# whether or not node has any descendants
	base_color_index		# color of this branch

	Node(initial_radius::AbstractFloat) =
		new(rand(),rand(),rand()*2.*pi,1,0,initial_radius,false,1)
	Node(x,y,theta,depth,n_branches,radius,has_descendant,base_color_index) =
		new(x,y,theta,depth,n_branches,radius,has_descendant,base_color_index)
end

abstract NodeCollection

type NodeArray <: NodeCollection
	nodes::Array{Node}
	grid::ZoneGrid
end
NodeArray(initial_radius::AbstractFloat) =
	NodeArray([],ZoneGrid(initial_radius))

function add_node(coll::NodeArray,node::Node)
	push!(coll.nodes,node)
	new_index=length(coll.nodes)
	add_node_ind(coll.grid,node.x,node.y,new_index)
	return new_index
end
gf(coll::NodeArray,s::Symbol,ind) =
	isa(ind,AbstractArray) ? [getfield(coll.nodes[i],s) for i in ind] : getfield(coll.nodes[ind],s)
get_x(coll::NodeArray,ind) = gf(coll,:x,ind)
get_y(coll::NodeArray,ind) = gf(coll,:y,ind)
get_theta(coll::NodeArray,ind) = gf(coll,:theta,ind)
get_depth(coll::NodeArray,ind) = gf(coll,:depth,ind)
get_nb(coll::NodeArray,ind) = gf(coll,:n_branches,ind)
get_r(coll::NodeArray,ind) = gf(coll,:radius,ind)
has_desc(col::NodeArray,ind) = gf(coll,:has_descendant,ind)
get_base_color_ind(col::NodeArray,int) = gf(coll,:base_color_index,ind)
set_nb(coll::NodeArray,ind::Int,nb) = (coll[i].n_branches=nb)
set_desc(coll::NodeArray,ind::Int,desc) = (coll[i].has_descendant=desc)

type CollapsedNodeCollection{F} <: NodeCollection
	x::Array{F}
	y::Array{F}
	theta::Array{F}
	depth::Array{Int}
	n_branches::Array{Int}
	radius::Array{F}
	has_descendant::Array{Bool}
	base_color_index::Array{Int}

	grid::ZoneGrid
end
CollapsedNodeCollection{F}(initial_radius::F) =
	CollapsedNodeCollection{F}([],[],[],[],[],[],[],[],ZoneGrid(initial_radius))

function add_node(coll::CollapsedNodeCollection,node::Node)
	push!(coll.x,node.x)
	push!(coll.y,node.y)
	push!(coll.theta,node.theta)
	push!(coll.depth,node.depth)
	push!(coll.n_branches,node.n_branches)
	push!(coll.radius,node.radius)
	push!(coll.has_descendant,node.has_descendant)
	push!(coll.base_color_index,node.base_color_index)
	new_index=length(coll.x)
	add_node_ind(coll.grid,node.x,node.y,new_index)
	return new_index
end
get_x(coll::CollapsedNodeCollection,i) = coll.x[i]
get_y(coll::CollapsedNodeCollection,i) = coll.y[i]
get_theta(coll::CollapsedNodeCollection,i) = coll.theta[i]
get_depth(coll::CollapsedNodeCollection,i) = coll.depth[i]
get_nb(coll::CollapsedNodeCollection,i) = coll.n_branches[i]
get_r(coll::CollapsedNodeCollection,i) = coll.radius[i]
has_desc(coll::CollapsedNodeCollection,i) = coll.has_descendant[i]
get_base_color_ind(coll::CollapsedNodeCollection,i) = coll.base_color_index[i]
set_nb(coll::CollapsedNodeCollection,i::Int,nb) = (coll.n_branches[i]=nb)
set_desc(coll::CollapsedNodeCollection,i::Int,desc) = (coll.has_descendant[i]=desc)

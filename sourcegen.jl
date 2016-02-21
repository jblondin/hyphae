function generate_random_nodes(nodecoll::NodeCollection,num_source_nodes::Int,
		initial_radius)
	for i in 1:num_source_nodes
		add_node(nodecoll,Node(initial_radius))
	end
	return num_source_nodes
end

# generate a random num_value-partitioning from 0.0 to 1.0
function generate_random_partitions(num_values::Int)
	r=rand(num_values)
	r/=sum(r)
	return [sum(r[1:i]) for i in 1:num_values]
end
# generate even num_value-partitioning from 0.0 to 1.0
function generate_even_partitions(num_values::Int)
	r=collect(0.0:1.0/(num_values):1.0)[2:end]
	return (r+rand())%1.0
end
function generate_wheelspoke_nodes(nodecoll::NodeCollection,num_source_nodes::Int,
		initial_radius,generate_partitions::Function,hub_radius::AbstractFloat)
	theta_coefs=generate_partitions(num_source_nodes)
	x=0.5
	y=0.5
	for i in 1:num_source_nodes
		theta=theta_coefs[i]*2.0*pi
		hub_x=x+sin(theta)*hub_radius
		hub_y=y+cos(theta)*hub_radius
		depth=1
		n_branches=0
		radius=initial_radius
		has_desc=false
		add_node(nodecoll,Node(hub_x,hub_y,theta,depth,n_branches,radius,has_desc,i))
	end
	return num_source_nodes
end
generate_wheelspoke_nodes(nodecoll::NodeCollection,num_source_nodes::Int,initial_radius,
	generate_partitions::Function) = generate_wheelspoke_nodes(nodecoll,num_source_nodes,
		initial_radius,generate_partitions,0.0)

# generate nodes at center pointing in random directions
generate_even_wheelspoke_nodes(nodecoll::NodeCollection,num_source_nodes::Int,initial_radius,
	hub_radius::AbstractFloat) = generate_wheelspoke_nodes(nodecoll,num_source_nodes,initial_radius,
		generate_even_partitions,hub_radius)
generate_even_wheelspoke_nodes(nodecoll::NodeCollection,num_source_nodes::Int,initial_radius) =
	generate_even_wheelspoke_nodes(nodecoll,num_source_nodes,initial_radius,0.0)
make_gen_even_wheelspoke_nodes_closure(hub_radius::AbstractFloat) =
	(nc,nsn,ir)->generate_even_wheelspoke_nodes(nc,nsn,ir,hub_radius)

# generate nodes from center pointing in roughly even directions away from each other
generate_random_wheelspoke_nodes(nodecoll::NodeCollection,num_source_nodes::Int,initial_radius,
	hub_radius::AbstractFloat) = generate_wheelspoke_nodes(nodecoll,num_source_nodes,initial_radius,
		generate_random_partitions,hub_radius)
generate_random_wheelspoke_nodes(nodecoll::NodeCollection,num_source_nodes::Int,initial_radius) =
	generate_random_wheelspoke_nodes(nodecoll,num_source_nodes,initial_radius,0.0)
make_gen_random_wheelspoke_nodes_closure(hub_radius::AbstractFloat) =
	(nc,nsn,ir)->generate_random_wheelspoke_nodes(nc,nsn,ir,hub_radius)


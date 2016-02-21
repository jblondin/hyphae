using Colors

include("render.jl")
include("zone.jl")
include("node.jl")
include("bordercheck.jl")
include("palette.jl")
include("sourcegen.jl")

type Stats
	n_branchouts::Int
	n_radiusouts::Int
	n_borderouts::Int
	n_conflicts::Int
	n_giveups::Int
end
Base.string(stats::Stats)="n_branchouts:$(stats.n_branchouts) " *
	"n_radiusouts:$(stats.n_radiusouts) n_borderouts:$(stats.n_borderouts) " *
	"n_conflicts:$(stats.n_conflicts) n_giveups:$(stats.n_giveups)"

function main()

	FILENAME="output"

	# size of image (both width and height)
	SIZE=15000
	# number of nodes until we draw / report stats
	DRAW_PERIOD=10000

	## Source node details
	# number of source nodes for initial population
	NUM_SOURCE_NODES=4
	# node generation style
	generate_nodes=generate_even_wheelspoke_nodes

	## Ending criteria
	# maximum number of branches for each node
	MAX_NUM_BRANCHES=15
	# maximum number of tries to branch from a node before giving up
	MAX_TRIES=50

	## Search circle configuration
	# initial radius of circle that's searched for travel direction
	INITIAL_RADIUS=0.004
	# reduction that occurs at every branch
	RADIUS_MULTIPLIER=0.9
	# minimum radius allowed for a branch
	MIN_RADIUS=1.0/SIZE
	# coefficient to compute width from radius size
	RADIUS_WIDTH_COEF=0.3
	# computing line width from radius
	radius_to_width(r)=r*SIZE*RADIUS_WIDTH_COEF
	# maximum angle to turn when branching
	MAX_SEARCH_ANGLE=pi

	## Colors
	# depth at which maximum desaturation is reached
	MAX_DESATURATION=25
	# color palette
	# palette=Palette(["#053000","#002421","#3b1a00","#3a003"],25)
	palette=Palette(["#9FDF99","#80BBB7","#FFD1AE","#FCACB0"],25)
	# color transformation style
	get_color_at_depth=get_exponential_saturated_color

	## Border type
	# border checking algorithm
	bordercheck=CircleBorderCheck(0.45)

	# renderer handles all the drawing
	renderer=Renderer(RGBA(1.0,1.0,1.0,1.0), RGBA(0.0,0.0,0.0,1.0),SIZE)

	# nodecoll keeps track of node details
	nodecoll=CollapsedNodeCollection(INITIAL_RADIUS)

	# queue of (node_index,num_tries) tuples to process
	nodequeue=[]

	num_generated=generate_nodes(nodecoll,NUM_SOURCE_NODES,INITIAL_RADIUS)

	if num_generated != NUM_SOURCE_NODES
		print("Warning: number of source nodes generated ($(num_generated)) not equal to " *
			"number expected ($(NUM_SOURCE_NODES))")
	end

	num_nodes=0
	for i in 1:num_generated
		push!(nodequeue,(i,0))
	end
	num_nodes += num_generated
	is_source_node(i) = i<=num_generated

	stats=Stats(0,0,0,0,0)
	tic()

	sum_neighbors=0
	num_neighbor_checks=0
	avg_num_neighbors()=sum_neighbors > 0 ? num_neighbor_checks/sum_neighbors : 0

	while length(nodequeue) > 0
		k,n_tries=shift!(nodequeue)

		if n_tries > MAX_TRIES
			# give up on this node, don't add back to queue
			stats.n_giveups+=1
			continue
		end

		n_branches=get_nb(nodecoll,k)+1

		if n_branches > MAX_NUM_BRANCHES
			# don't add back to queue
			stats.n_branchouts+=1
			continue
		end

		r=get_r(nodecoll,k) * (has_desc(nodecoll,k) ? RADIUS_MULTIPLIER : 1.0)
		if r < MIN_RADIUS
			# don't add back to queue
			stats.n_radiusouts+=1
			continue
		end

		# find new angle of travel
		depth=get_depth(nodecoll,k) + (has_desc(nodecoll,k) ? 1 : 0)
		theta=get_theta(nodecoll,k)+(1.0-1.0/((depth+1)^0.1))*randn()*MAX_SEARCH_ANGLE

		# compute new location
		x=get_x(nodecoll,k)+sin(theta)*r
		y=get_y(nodecoll,k)+cos(theta)*r

		## check against border (make sure still in-bounds)
		if !in_bounds(bordercheck,x,y)
			# add back to queue
			push!(nodequeue,(k,n_tries+1))
			stats.n_borderouts+=1
			continue
		end

		# check against neighboring nodes
		neighbor_node_inds=filter(k0->k0!=k,get_neighbor_node_inds(nodecoll.grid,x,y))
		sum_neighbors+=length(neighbor_node_inds)
		num_neighbor_checks+=1
		if length(neighbor_node_inds) > 0
			# println("$k $neighbor_node_inds")
			neighbor_x=get_x(nodecoll,neighbor_node_inds)
			neighbor_y=get_y(nodecoll,neighbor_node_inds)
			neighbor_r=get_r(nodecoll,neighbor_node_inds)
			dist_sqrd=(neighbor_x-x).^2+(neighbor_y-y).^2
			# all neighbors need to be at least (neighbor radius + node radius)/2 away
			# compare squard values to avoid sqrt
			if !all(dist_sqrd.*4 .>= (neighbor_r+r).^2)
				# add back to queue
				push!(nodequeue,(k,n_tries+1))
				stats.n_conflicts+=1
				# println("$k $neighbor_x $neighbor_y $x $y $(dist_sqrd.*4) $((neighbor_r+r).^2) $neighbor_r $r")
				continue
			end
		end

		## save computed values
		newk=add_node(nodecoll,Node(x,y,theta,depth,0,r,false,get_base_color_ind(nodecoll,k)))

		## draw
		line(renderer,Point(get_x(nodecoll,k),get_y(nodecoll,k)),Point(x,y),
			radius_to_width(get_r(nodecoll,k)),
			get_color_at_depth(palette,get_base_color_ind(nodecoll,k),get_depth(nodecoll,k)))

		# update previous node
		set_desc(nodecoll,k,true)
		set_nb(nodecoll,k,n_branches)

		num_nodes+=1
		if num_nodes % DRAW_PERIOD == 0
			elapsed=toq()
			println("$num_nodes $(length(nodequeue)) $(string(stats)) " *
				"avg_num_neighbors:$(avg_num_neighbors()) elapsed:$(elapsed)s")
			save(renderer,"$(FILENAME).$(num_nodes).png")
			sum_neighbors=0
			num_neighbor_checks=0
			tic()
		end

		# add both new node and old node to queue
		# reset the numbers of tries on the old node, since it still has room to grow
		append!(nodequeue,[(k,0),(newk,0)])
	end
	elapsed=toq()
	println("final $num_nodes $(string(stats)) avg_num_neighbors:$(avg_num_neighbors()) " *
		"elapsed:$(elapsed)s")
	save(renderer,"$(FILENAME).png")
end

main()

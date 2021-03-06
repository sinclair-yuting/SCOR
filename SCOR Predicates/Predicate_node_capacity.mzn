/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      SCOR Predicate for link utilization
*  Objective: Finds the capacity of nodes
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

predicate node_capacity(
          array[int,int] of var 0..1: Link_Path_Membership,              % array[1..num_edges,1..nFlows] of var 0..1: x
          array[int] of int: Flow_demands,                               % array[1..nFlows] of int: Flow_demands
          array[int,int] of int: Link_info,                              % array[1..num_links,1..4] of 1..99: Link_info)
          array[int] of int: Nodes_Capacity) =                           % array[1..num_nodes] of int: capacity of nodes
                        
let {
     int: nFlows = max(index_set(Flow_demands)),
     int: num_links = max(index_set_1of2(Link_info)),
     int: num_nodes = max(index_set(Nodes_Capacity)),
     array[int,int] of var 0..1: x = Link_Path_Membership,
     array[1..num_nodes] of var int: node_flow_in,
     array[1..num_nodes] of var int: node_flow_out,
}
in
    (
     assert(
            max(index_set_1of2(x)) == num_links
            /\
            lb_array(x) == 0
            /\
            ub_array(x) == 1,
            "Error: explain this assert error message.",
            forall(i in 1..num_nodes)(
                     node_flow_in[i] =
                          sum(k in 1..num_links, j in 1..nFlows)(
                              if Link_info[k,2] = i then membership[k,j]*Flow_demands[j] else 0 endif
                          )
                     /\
                     node_flow_out[i] =
                          sum(k in 1..num_links, j in 1..nFlows)(
                              if Link_info[k,1] = i then membership[k,j]*Flow_demands[j] else 0 endif
                          )
                     /\
                     node_flow_in[i] + node_flow_out[i] <= Nodes_Capacity[i]
            )
     )
);



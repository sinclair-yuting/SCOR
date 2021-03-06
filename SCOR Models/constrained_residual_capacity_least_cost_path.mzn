/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      SCOR Model for Constrained residual capacity least cost path
*  Objective: Finds the flow paths that has a specified residual capacity with least cost
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  Note: If running in MiniZinc IDE, the model data can be opened, and fed to the model via Project Explorer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

%%%%%%%%% Calling Predicates  %%%%%%%%%%%%
include "../SCOR Predicates/Predicate_flow_path.mzn";
include "../SCOR Predicates/Predicate_path_cost.mzn";
include "../SCOR Predicates/Predicate_residual_capacity.mzn";


%%%%%%%%%%%%%%%%% Declaration  %%%%%%%%%%%%
% Only for using with the supplied model data files
% (These three parameters are declared because they are used in the model data files).
int: c1;
int: c2;
int: c3;

% Residual Capacity Limit Ratio (0 <= RCLR <= 1 {if < 0 converts to overbooking})
float: RCLR = 0.1; 

% link parameters
int: d1;
int: d2;
array[int, int] of int: Link_info;
int: num_links = max(index_set_1of2(Link_info));

% capacity of links should be more than these values (used in other programs, here just for unifying) 
array[1..nFlows] of int: Limits;

% nodes
array[int] of int: Nodes;

% Flow Demands
array[int] of int: Flow_demands;
int: nFlows = max(index_set(Flow_demands));

% source node 
array[1..nFlows] of int: s;

% target node 
array[1..nFlows] of int: t;

% link membership in the path
array[1..num_links,1..nFlows] of var 0..1: membership;  

% objective function is the path length to be minimized 
array[1..1] of var int: Tcost;

% the residual capacity in each link
array[1..num_links] of var int  : Residual;  
array[1..num_links] of var int:Residual_defined_capacity;


%%%%%%%%%%%%%%%% Constraints %%%%%%%%%%%
% Calculate all paths from s to t (apply Flow Conservation Constraint)
constraint flow_path( membership, Link_info, Nodes, s, t);

% Calculate total distance for each possible path 
constraint path_cost( membership, Link_info, Tcost, Flow_demands);

% Calculate the residual capacity in each link
constraint residual_capacity( membership, Flow_demands, Link_info, Residual );

% Calculate the overbooking value in each link (separately just because it decreases solver time)
constraint forall(i in 1..num_links)(Residual_defined_capacity[i] = RCLR*Link_info[i,4]);

% Limit the the total flow in each link to less than its capacity plus the overbooking
constraint forall(i in 1..num_links)(Residual[i] >= RCLR);


%%%%%%%%%%%%%%  Solve  %%%%%%%%%%%%%%%%%
solve minimize Tcost[1];


%%%%%%%%%%%%%  Formatted Output %%%%%%%%%%%%%%%%%%%
output [
if i = 1 then
    "\n\n********************* Flow[\(j)] demand = \(Flow_demands[j]) *********************\n" ++
    "Path [Link no (n1-n2)]:  " ++
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] ==>" endif
elseif i = num_links then 
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] " endif ++ "\n"
else
    if fix(membership[i,j]) = 0 then "" else " [ln:"++show_int(-2,i) endif ++
    if fix(membership[i,j]) = 0 then "" else " ("++show_int(2,Link_info[i,1])++
    "->"++show_int(-2,Link_info[i,2])++") R:"++show_int(-2,fix(Residual[i]))++"] ==>" endif
endif | j in 1..nFlows,i in 1.. num_links] ++
        ["\nTotal cost:    [\(fix(Tcost[1]))]"];


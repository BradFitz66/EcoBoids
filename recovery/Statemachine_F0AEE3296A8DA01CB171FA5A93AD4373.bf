using System;
using System.Collections;
namespace Boids.lib
{
	typealias StateUpdate = function void(ref Boid b);

	public struct State{
		public StateUpdate update;
		public Boid assignedTo;
		public String stateId;

		public this(Boid assigned, StateUpdate upd, String id){
			assignedTo=assigned;
			update=upd;
			stateId=id;
		}
	}

	public class Statemachine : List<State>
	{
		//Current state is always at index 0
		public State curState => this[0];

		public void SwitchState(String newCurrentState){
			int ind=FindIndex(scope (x)=>{return x.stateId==newCurrentState;});
			if(ind==-1)
				return;
			State item = this[ind];
			RemoveAtFast(ind);
			Insert(0,item);
		}

		public void Update(){
			//Ugly, but it's the only solution. Maybe an ECS will fix this?
			if(Count>0)
				curState.update(ref curState.assignedTo);
		}
	}
}

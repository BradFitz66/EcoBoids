using System;
using System.Collections;
namespace Boids.lib
{
	/*
	Title: Statemachine
	Description: Simple statemachine for simple AI like Boids.
	*/
	typealias StateUpdate = function void(ref Entity e);
	public struct State{
		public StateUpdate update;
		public Entity assignedTo;
		public String stateId;

		public this(Entity assigned, StateUpdate upd, String id){
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
			if(Count>0)
				curState.update(ref curState.assignedTo);
		}
	}
}

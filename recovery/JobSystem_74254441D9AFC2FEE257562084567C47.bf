using System;
using System.Collections;

namespace Boids.lib.JobSystem
{
	public struct JobDispatchArgs{
		uint32 jobIndex;
		uint32 groupIndex;
		void JobDispatchArgs(){
			
		}
	}

	public abstract class JobSystem
	{
		public abstract void Initialize();
		public abstract void Execute(Action job);

		public abstract void Dispact(uint32 jobCount, uint32 groupSize, delegate void(JobDispatchArgs) job);

		public abstract bool IsBusy();
		public abstract void Wait();


	}
}

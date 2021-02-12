namespace Boids.lib.JobSystem
{
	interface IJob
	{
		public ~this(){}
		bool invoke(void* args, int aIndex){return false;};
		
	}

	class JobFunc : IJob{
		public this(void* aFunc_Ptr){}
	}
}

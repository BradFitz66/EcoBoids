using System.Collections;
using System.Threading;
using System;
using System.Diagnostics;
namespace Boids.lib
{
	class FlockManager : List<Flock>
	{
		int threadNum;
		List<Thread> threads;
		public Flock this[int index] => this[index];
		public this()
		{
			threadNum = (scope ThreadStats()).mMax;
			if (threadNum == 0)
				threadNum = 1;
			threads = new List<Thread>(threadNum);
		}

		public ~this()
		{
			for (int i = 0; i < threadNum; i++)
			{
				threads[i].Join();
			}
			DeleteContainerAndItems!(threads);
			delete(this);
		}
		public void Draw()
		{
		}
		public void Update()
		{
			int32 batchSize = (int32)(BoidsAmount / threadNum);
			for(int i=0; i<threadNum; ++i){
				threads[i]=new Thread(scope ()=>{BatchUpdatePositions;},batchSize);
			}
			for(int i=0; i<threadNum; ++i){
				threads[i].Join();
			}
			for(int i=0; i<Count; i++){
				this[i].Update();
			}
		}

		public void BatchUpdatePositions(int offset){
		}
	}
}

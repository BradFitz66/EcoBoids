using System;
using System.Collections;

namespace Boids.lib.JobSystem
{
	public class ThreadSafeRingBuffer<T> : IEnumerable<T>
	{
		public bool push_back(T item){
			bool result=false;
			lock.lock()
			return result;
		}
		public IEnumerator<T> GetEnumerator()
		{
			return default;
		}

		
	}
}
